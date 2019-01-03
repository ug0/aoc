defmodule Group do
  defstruct [:units, :hp, :attack_damage, :attack_type, :initiative, :weaknesses, :immunities]

  def new(units, hp, attack_damage, attack_type, initiative, weaknesses, immunities) do
    %Group{
      units: units,
      hp: hp,
      attack_damage: attack_damage,
      attack_type: attack_type,
      initiative: initiative,
      weaknesses: weaknesses,
      immunities: immunities
    }
  end

  def defend_attacking(defender = %Group{}, _attacker = %Group{units: 0}) do
    defender
  end

  def defend_attacking(defender = %Group{}, attacker = %Group{}) do
    defend_attacking(defender, damage(attacker, defender))
  end

  def defend_attacking(defender = %Group{units: units, hp: hp}, damage) do
    %Group{defender | units: max(0, units - div(damage, hp))}
  end

  def effective_power(%Group{units: units, attack_damage: attack_damage}),
    do: units * attack_damage

  def damage(attacker = %Group{attack_type: attack_type}, %Group{
        immunities: immunities,
        weaknesses: weaknesses
      }) do
    cond do
      attack_type in immunities -> 0
      attack_type in weaknesses -> 2 * default_damage(attacker)
      true -> default_damage(attacker)
    end
  end

  defp default_damage(attacker = %Group{}), do: effective_power(attacker)
end

defmodule Day24 do
  def part1(input) do
    {immune_groups, infection_groups} = parse_input(input)

    mix_groups(immune_groups, infection_groups)
    |> fight()
  end

  # binary-search might not work for some input: https://www.reddit.com/r/adventofcode/comments/a997m1/2018_day_24_binary_search_or_not/
  def part2(input) do
    {immune_groups, infection_groups} = parse_input(input)

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while(nil, fn boost, acc ->
      immune_groups =
        immune_groups
        |> Enum.map(fn %Group{attack_damage: attack_damage} = group ->
          %Group{group | attack_damage: attack_damage + boost}
        end)

      case mix_groups(immune_groups, infection_groups) |> fight() do
        {:immune, units_count} -> {:halt, units_count}
        _ -> {:cont, acc}
      end
    end)
  end

  def fight(groups) do
    fight(groups, {immune_units_count(groups), infection_units_count(groups)})
  end

  def fight(groups, {immune_units, infection_units}) do
    cond do
      immune_units == 0 ->
        {:infection, infection_units}
      infection_units == 0 ->
        {:immune, immune_units}

      true ->
        selections = selection_phase(groups)
        groups = attacking_phase(groups, selections)

        case {groups, {immune_units_count(groups), infection_units_count(groups)}} do
          {_, {^immune_units, ^infection_units}} -> :no_winner
          {groups, {immune_units, infection_units}} -> fight(groups, {immune_units, infection_units})
        end
    end
  end

  def mix_groups(immune_groups, infection_groups) do
    immune_groups
    |> Stream.with_index(1)
    |> Enum.into(%{}, fn {unit, index} -> {{:immune, index}, unit} end)
    |> Map.merge(
      infection_groups
      |> Stream.with_index(1)
      |> Enum.into(%{}, fn {unit, index} -> {{:infection, index}, unit} end)
    )
  end

  def selection_phase(groups) do
    sorted_groups = sort_groups(groups)

    {selections, _} =
      Enum.reduce(sorted_groups, {[], MapSet.new()}, fn {attacker_id = {attacker_type, _},
                                                  attacker = %Group{}},
                                                 {selections, selected} ->
        case choose_target(attacker, attacker_type, sorted_groups, selected) do
          nil ->
            {selections, selected}

          {defender_id, _} ->
            {[{attacker_id, defender_id, attacker.initiative} | selections],
             MapSet.put(selected, defender_id)}
        end
      end)

    Enum.sort_by(selections, fn {_, _, i} -> i end, &>=/2)
  end

  def attacking_phase(groups, selections) do
    Enum.reduce(selections, groups, fn {attacker_id, defender_id, _}, groups ->
      defender = Group.defend_attacking(groups[defender_id], groups[attacker_id])
      %{groups | defender_id => defender}
    end)
  end

  defp immune_units_count(groups), do: units_count(groups, :immune)
  defp infection_units_count(groups), do: units_count(groups, :infection)
  defp units_count(groups, type) do
    groups
    |> Stream.filter(fn {{t, _}, _} -> t == type end)
    |> Enum.map(fn {_, %Group{units: units}} -> units end)
    |> Enum.sum()
  end

  def choose_target(%Group{} = attacker, attacker_type, sorted_groups, selected) do
    sorted_groups
    |> Stream.reject(fn {id = {defender_type, _}, _} ->
      defender_type == attacker_type || MapSet.member?(selected, id)
    end)
    |> Stream.map(fn {id, %Group{} = target} -> {id, {Group.damage(attacker, target), Group.effective_power(target), target.initiative}} end)
    |> Stream.reject(fn {_id, {damage, _, _}} -> damage == 0 end)
    |> Enum.max_by(fn {_id, weight} -> weight end, fn -> nil end)
  end

  def sort_groups(groups) do
    groups
    |> Stream.filter(fn {_, %Group{units: units}} -> units > 0 end)
    |> Enum.sort_by(
      fn {_, unit = %Group{initiative: initiative}} ->
        {Group.effective_power(unit), initiative}
      end,
      &>=/2
    )
  end

  def parse_input(input) do
    ["Immune System:\n" <> immune, "Infection:\n" <> infection] = String.split(input, "\n\n")

    {
      immune |> String.split("\n", trim: true) |> Enum.map(&parse_group/1),
      infection |> String.split("\n", trim: true) |> Enum.map(&parse_group/1)
    }
  end

  defp parse_group(line) do
    [first_part, attack_and_initiative] =
      String.split(line, " with an attack that does ", trim: true)

    [units, hp] = String.split(first_part, ~r/[^\d]/, trim: true)
    %{weaknesses: weaknesses, immunities: immunities} = parse_features(first_part)

    [attack_damage, attack_type, initiative] =
      String.split(attack_and_initiative, [" damage at initiative ", " "])

    Group.new(
      String.to_integer(units),
      String.to_integer(hp),
      String.to_integer(attack_damage),
      attack_type,
      String.to_integer(initiative),
      weaknesses,
      immunities
    )
  end

  defp parse_features(line) do
    init_features = %{weaknesses: [], immunities: []}

    case Regex.scan(~r/\((.+)\)/, line, capture: :all_but_first) do
      [] ->
        init_features

      [[features]] ->
        features |> String.split("; ") |> Enum.map(&parse_feature/1) |> Enum.into(init_features)
    end
  end

  defp parse_feature("weak to " <> features), do: {:weaknesses, String.split(features, ", ")}
  defp parse_feature("immune to " <> features), do: {:immunities, String.split(features, ", ")}
  defp parse_feature(_), do: []
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day24Test do
      use ExUnit.Case

      @input """
      Immune System:
      17 units each with 5390 hit points (weak to radiation, bludgeoning) with an attack that does 4507 fire damage at initiative 2
      989 units each with 1274 hit points (immune to fire; weak to bludgeoning, slashing) with an attack that does 25 slashing damage at initiative 3

      Infection:
      801 units each with 4706 hit points (weak to radiation) with an attack that does 116 bludgeoning damage at initiative 1
      4485 units each with 2961 hit points (immune to radiation; weak to fire, cold) with an attack that does 12 slashing damage at initiative 4
      """
      test "part 1 result" do
        assert Day24.part1(@input) == {:infection, 5216}
      end

      test "part 2 result" do
        assert Day24.part2(@input) == 51
      end
    end

  [input, "--part1"] ->
    input
    |> File.read!()
    |> Day24.part1()
    |> IO.inspect()

  [input, "--part2"] ->
    input
    |> File.read!()
    |> Day24.part2()
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input_file]")
end
