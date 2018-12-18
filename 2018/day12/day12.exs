defmodule Day12 do
  def part1([initial_state | rules]) do
    pots = initial_state |> parse_pots() |> Pots.init()
    parsed_rules = rules |> parse_rules()

    1..20
    |> Enum.each(fn _ ->
      Pots.next_gen!(pots, parsed_rules)
    end)

    Pots.plant_sum(pots)
  end

  @doc """
  经过一定次数的迭代，状态分布会出现循环并且整体位置逐渐向右偏移。
  """
  def part2([initial_state | rules]) do
    pots = initial_state |> parse_pots() |> Pots.init()
    parsed_rules = rules |> parse_rules()

    total_gens = 50000000000
    1..total_gens
    |> Enum.reduce_while(%{Pots.trimmed_string(pots) => {0, Pots.plant_sum(pots)}}, fn gen, acc ->
      Pots.next_gen!(pots, parsed_rules)
      trimmed_pots_string = Pots.trimmed_string(pots)
      plant_sum = Pots.plant_sum(pots)

      case Map.get(acc, trimmed_pots_string) do
        nil -> {:cont, Map.put(acc, trimmed_pots_string, {gen, plant_sum})}
        {last_repeated_gen, last_repeated_sum} ->
          cycle_size = gen - last_repeated_gen
          gen_offset = rem(total_gens - last_repeated_gen, cycle_size)
          next_repeated_gen = last_repeated_gen + gen_offset
          cycles = div(total_gens - last_repeated_gen, cycle_size)
          offset_per_cycle = div(plant_sum - last_repeated_sum, pots |> Pots.trimmed_string() |> String.replace(" ", "") |> String.length())

          {str, {_, sum}} = Enum.find(acc, fn {_, {gen, _sum}} -> gen == next_repeated_gen end)
          {:halt, sum + cycles * offset_per_cycle * (str |> String.replace(" ", "") |> String.length())}
      end
    end)
  end

  def parse_pots("initial state: " <> pots) do
    pots
    |> String.graphemes()
    |> Stream.with_index()
  end

  def parse_rules(rules) do
    rules
    |> Stream.map(&parse_rule/1)
    |> Enum.into(%{})
  end

  defp parse_rule(input) do
    input |> String.split(" => ") |> List.to_tuple()
  end
end

defmodule Pots do
  @has_plant "#"
  @has_no_plant "."

  def init(initial_pots) do
    pots = :ets.new(__MODULE__, [:ordered_set, :protected])

    initial_pots
    |> Enum.each(fn {state, pot} ->
      :ets.insert(pots, {pot, state})
    end)

    pots
  end

  def next_gen!(pots, rules) do
    update_next_gen(pots, pots |> to_list() |> extend_left(), rules)
  end

  def to_list(pots) do
    pots_list = [{first, _} | _] = :ets.select(pots, [{:"$1", [], [:"$1"]}])
    [{first - 2, @has_no_plant}, {first - 1, @has_no_plant} | pots_list]
  end

  defp extend_left(pots_list = [{first, @has_plant} | _]) do
    [{first - 4, @has_no_plant}, {first - 3, @has_no_plant}, {first - 2, @has_no_plant}, {first - 1, @has_no_plant} | pots_list]
  end

  defp extend_left(pots_list = [{first, @has_no_plant}, {_, @has_plant} | _]) do
    [{first - 3, @has_no_plant}, {first - 2, @has_no_plant}, {first - 1, @has_no_plant} | pots_list]
  end

  defp extend_left(pots_list = [{first, _} | _]) do
    [{first - 2, @has_no_plant}, {first - 1, @has_no_plant} | pots_list]
  end

  @ms_pot_has_plant [{{:"$1", @has_plant}, [], [:"$1"]}]
  def plant_sum(pots) do
    :ets.select(pots, @ms_pot_has_plant) |> Enum.sum()
  end

  def trimmed_string(pots) do
    pots
    |> Pots.to_list()
    |> Stream.map(fn {_, state} -> state end)
    |> Enum.join("")
    |> String.replace(@has_no_plant, " ")
    |> String.trim()
  end

  defp update_next_gen(
         pots,
         list = [{_, state_l2}, {_, state_l1}, {cur, state_cur}, {_, state_r1}, {_, state_r2} | _],
         rules
       ) do
    update_pot_state(pots, cur, result_by_rule(rules, {state_l2, state_l1, state_cur, state_r1, state_r2}), state_cur)

    update_next_gen(pots, tl(list), rules)
  end

  defp update_next_gen(pots, [{_, state_l2}, {_, state_l1}, {cur, state_cur}, {r1, state_r1} | []], rules) do
    update_pot_state(pots, cur, result_by_rule(rules, {state_l2, state_l1, state_cur, state_r1, @has_no_plant}), state_cur)
    update_pot_state(pots, r1, result_by_rule(rules, {state_l1, state_cur, state_r1, @has_no_plant, @has_no_plant}), state_r1)

    case {state_cur, state_r1} do
      {@has_no_plant, @has_no_plant} -> :ok
      {_, @has_no_plant} ->
        update_pot_state(pots, r1 + 1, result_by_rule(rules, {state_cur, state_r1, @has_no_plant, @has_no_plant, @has_no_plant}))
      _ ->
        update_pot_state(pots, r1 + 1, result_by_rule(rules, {state_cur, state_r1, @has_no_plant, @has_no_plant, @has_no_plant}))
        update_pot_state(pots, r1 + 2, result_by_rule(rules, {state_r1, @has_no_plant, @has_no_plant, @has_no_plant, @has_no_plant}))
    end
  end

  defp update_pot_state(pots, pot, new_state, current_state \\ @has_no_plant)
  defp update_pot_state(_, _, state, state), do: nil
  defp update_pot_state(pots, pot, new_state, _old_state) do
    :ets.insert(pots, {pot, new_state})
  end

  defp result_by_rule(rules, states) do
    Map.get(rules, states |> Tuple.to_list() |> Enum.join(""), @has_no_plant)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day11Test do
      use ExUnit.Case

      @input """
      initial state: #..#.#..##......###...###

      ...## => #
      ..#.. => #
      .#... => #
      .#.#. => #
      .#.## => #
      .##.. => #
      .#### => #
      #.#.# => #
      #.### => #
      ##.#. => #
      ##.## => #
      ###.. => #
      ###.# => #
      ####. => #
      """
      test "part1 result" do
        assert 325 == Day12.part1(@input |> String.split("\n", trim: true))
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Day12.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Day12.part2()
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
