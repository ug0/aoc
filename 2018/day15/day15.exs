defmodule Day15 do
  defmodule Unit do
    alias Day15.Unit

    defstruct [:hp, :kind]

    def new(kind) when kind in 'EG', do: %Unit{hp: 200, kind: kind}

    def status(%Unit{hp: hp, kind: kind}), do: "#{<<kind>>}(#{hp})"

    def damaged(%Unit{hp: hp}, damage) when hp <= damage, do: :dead
    def damaged(%Unit{hp: hp} = unit, damage), do: %Unit{unit | hp: hp - damage}
  end

  defmodule Battleground do
    alias Battleground, as: Ground
    alias Day15.Unit

    defstruct [:map, :round, :damage]

    def from_raw_input(
          input,
          damage \\ fn
            %Unit{kind: ?E} -> 3
            %Unit{kind: ?G} -> 3
          end
        ) do
      map =
        input
        |> String.split("\n", trim: true)
        |> Stream.with_index()
        |> Enum.reduce(%{}, fn {line, y}, map ->
          line
          |> String.to_charlist()
          |> Stream.with_index()
          |> Enum.reduce(map, fn {symbol, x}, map ->
            Map.put(
              map,
              {x, y},
              case symbol do
                unit when unit in 'EG' -> Unit.new(unit)
                wall_or_cavern when wall_or_cavern in '.#' -> wall_or_cavern
              end
            )
          end)
        end)

      %Ground{map: map, round: 0, damage: damage}
    end

    def fight_to_death(ground) do
      fight_to_death(ground, sorted_unit_coords(ground))
    end

    def fight_to_death(ground = %Ground{round: round}, []) do
      fight_to_death(%Ground{ground | round: round + 1}, sorted_unit_coords(ground))
    end

    def fight_to_death(%Ground{} = ground, [next_turn | rest]) do
      ground = ground |> play_turn(next_turn)

      case Enum.reduce(ground.map, {0, 0}, fn
             {_, %Unit{kind: ?G}}, {e_count, g_count} -> {e_count, g_count + 1}
             {_, %Unit{kind: ?E}}, {e_count, g_count} -> {e_count + 1, g_count}
             _, acc -> acc
           end) do
        {e_count, g_count} when e_count == 0 or g_count == 0 ->
          full_round = case rest do
            [] -> ground.round + 1
            _ -> ground.round
          end
          {ground, full_round, e_count, g_count}

        _ ->
          fight_to_death(ground, rest)
      end
    end

    def sorted_unit_coords(%Ground{map: map}) do
      map
      |> Stream.filter(fn
        {_, %Unit{}} -> true
        _ -> false
      end)
      |> Stream.map(fn {coord, _} -> coord end)
      |> Enum.sort_by(fn {x, y} -> {y, x} end)
    end

    def play_turn(ground = %Ground{}, target) do
      case possible_actions(ground, target) do
        {[], []} ->
          ground

        {[], _movable_positions} ->
          move(ground, target, shortest_move_to_enemy(ground, target))

        {enemies, _} ->
          attack_weakest_enemy(ground, enemies)
      end
    end

    def attack(ground = %Ground{map: map, damage: damage}, target) do
      new_map =
        case Unit.damaged(map[target], damage.(map[target])) do
          :dead -> %{map | target => ?.}
          unit -> %{map | target => unit}
        end

      %Ground{ground | map: new_map}
    end

    def attack_weakest_enemy(ground, enemies) do
      attack(ground, enemies |> Enum.min_by(fn {_, %Unit{hp: hp}} -> hp end) |> elem(0))
    end

    def move(ground, _, nil), do: ground

    def move(ground = %Ground{map: map}, from, to) do
      new_ground = %Ground{ground | map: %{map | from => ?., to => map[from]}}

      case possible_actions(new_ground, to) do
        {[], _} -> new_ground
        {enemies, _} -> attack_weakest_enemy(new_ground, enemies)
      end
    end

    def total_hp(%Ground{map: map}) do
      map
      |> Stream.map(fn
        {_, %Unit{hp: hp}} -> hp
        _ -> 0
      end)
      |> Enum.sum()
    end

    def possible_actions(ground = %Ground{map: map}, coord) do
      with unit = %Unit{} <- map[coord] do
        ground
        |> adjacent_targets(coord)
        |> Stream.filter(fn
          {_, %Unit{kind: kind}} -> kind != unit.kind
          {_, ?.} -> true
          _ -> false
        end)
        |> Enum.split_with(fn
          {_, %Unit{}} -> true
          _ -> false
        end)
      else
        _ -> {[], []}
      end
    end

    def reachable_ranges(ground = %Ground{}, coord) do
      ground
      |> adjacent_targets(coord)
      |> Stream.filter(fn {_, target} -> target == ?. end)
      |> Enum.map(fn {coord, _} -> coord end)
    end

    def shortest_move_to_enemy(ground = %Ground{map: map}, target) do
      kind = map[target].kind

      enemy_ranges =
        map
        |> Stream.filter(fn
          {_, %Unit{kind: ^kind}} -> false
          {_, %Unit{}} -> true
          _ -> false
        end)
        |> Stream.flat_map(fn {coord, _} -> reachable_ranges(ground, coord) end)
        |> Stream.uniq()

      ground
      |> reachable_ranges(target)
      |> Stream.flat_map(fn next_move ->
        distance_data = reachable_endpoints(ground, next_move)

        enemy_ranges
        |> Stream.map(fn coord -> {next_move, distance_data[coord]} end)
        |> Stream.filter(fn {_, distance} -> distance end)
      end)
      |> Enum.min_by(fn {_, distance} -> distance end, fn -> {nil, nil} end)
      |> elem(0)
    end

    def adjacent_targets(%Ground{map: map}, {x, y}) do
      [
        {x, y - 1},
        {x - 1, y},
        {x + 1, y},
        {x, y + 1}
      ]
      |> Enum.map(fn coord -> {coord, map[coord]} end)
    end

    def reachable_endpoints(ground = %Ground{}, coord) do
      bfs_search(
        ground,
        %{coord => 0},
        ground |> reachable_ranges(coord) |> Enum.map(&{coord, &1})
      )
    end

    defp bfs_search(_ground, closed_set, _open_set = []), do: closed_set

    defp bfs_search(ground = %Ground{}, closed_set, open_set) do
      {closed_set, visited} =
        open_set
        |> Enum.reduce({closed_set, []}, fn {parent, coord}, {closed_set, visited} ->
          new_visited =
            ground
            |> reachable_ranges(coord)
            |> Stream.map(&{coord, &1})
            |> Stream.concat(visited)
            |> Stream.uniq_by(fn {_, coord} -> coord end)
            |> Enum.reject(fn {_, coord} -> closed_set[coord] end)

          distance = closed_set[parent] + 1
          closed_set = Map.update(closed_set, coord, distance, &min(distance, &1))

          {closed_set, new_visited}
        end)

      bfs_search(ground, closed_set, visited)
    end

    # Just for fun and debugging
    def display(%Ground{map: map}) do
      {{{min_x, _}, _}, {{max_x, _}, _}} = Enum.min_max_by(map, fn {{x, _}, _} -> x end)
      {{{_, min_y}, _}, {{_, max_y}, _}} = Enum.min_max_by(map, fn {{_, y}, _} -> y end)

      Enum.each(min_y..max_y, fn y ->
        {line, units_status} =
          Enum.reduce(min_x..max_x, {[], []}, fn x, {line, units_status} ->
            case map[{x, y}] do
              %Unit{} = unit -> {[unit.kind | line], [Unit.status(unit) | units_status]}
              wall_or_cavern -> {[wall_or_cavern | line], units_status}
            end
          end)

        line = Enum.reverse(line)
        units_status = units_status |> Enum.reverse() |> Enum.join(", ")
        IO.puts(line ++ '  ' ++ units_status)
      end)

      IO.puts("\n")
    end
  end

  alias Day15.Battleground, as: Ground
  alias Day15.Unit

  def part1(input) do
    {ground, full_round, _e_count, _g_count} =
      input
      |> Ground.from_raw_input()
      |> Ground.fight_to_death()

    full_round * Ground.total_hp(ground)
  end

  def part2(input, power_of_elf) do
    ground =
      Ground.from_raw_input(input, fn
        %Unit{kind: ?G} -> power_of_elf
        %Unit{kind: ?E} -> 3
      end)

    elves_count =
      Enum.count(ground.map, fn
        {_, %Unit{kind: ?E}} -> true
        _ -> false
      end)

    {ground, full_round, e_count, g_count} = Ground.fight_to_death(ground)

    case {e_count, g_count} do
      {^elves_count, 0} -> {:win, full_round * Ground.total_hp(ground)}
      {0, _} -> :lost
      {_, 0} -> :not_win
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day15Test do
      use ExUnit.Case

      @input """
      #######
      #.G...#
      #...EG#
      #.#.#G#
      #..G#E#
      #.....#
      #######
      """
      test "part1 result 1" do
        assert 27730 == Day15.part1(@input)
      end

      @input """
      #######
      #G..#E#
      #E#E.E#
      #G.##.#
      #...#E#
      #...E.#
      #######
      """
      test "part1 result 2" do
        assert 36334 == Day15.part1(@input)
      end

      @input """
      #######
      #E..EG#
      #.#G.E#
      #E.##E#
      #G..#.#
      #..E#.#
      #######
      """
      test "part1 result 3" do
        assert 39514 == Day15.part1(@input)
      end

      @input """
      #######
      #E.G#.#
      #.#G..#
      #G.#.G#
      #G..#.#
      #...E.#
      #######
      """
      test "part1 result 4" do
        assert 27755 == Day15.part1(@input)
      end

      @input """
      #######
      #.E...#
      #.#..G#
      #.###.#
      #E#G#G#
      #...#G#
      #######
      """
      test "part1 result 5" do
        assert 28944 == Day15.part1(@input)
      end

      @input """
      #########
      #G......#
      #.E.#...#
      #..##..G#
      #...##..#
      #...#...#
      #.G...G.#
      #.....G.#
      #########
      """
      test "part1 result 6" do
        assert 18740 == Day15.part1(@input)
      end

      @input """
      #######
      #.G...#
      #...EG#
      #.#.#G#
      #..G#E#
      #.....#
      #######
      """
      test "part2 result" do
        assert {:win, 4988} == Day15.part2(@input, 15)
      end
    end

  [input, "--part1"] ->
    input
    |> File.read!()
    |> Day15.part1()
    |> IO.inspect()

  [input, power_of_elf, "--part2"] ->
    input
    |> File.read!()
    |> Day15.part2(power_of_elf |> String.to_integer())
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "wrong usage")
end
