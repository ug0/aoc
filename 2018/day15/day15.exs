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

    defstruct [:map, :round]

    def from_raw_input(input) do
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

      %Ground{map: map, round: 0}
    end

    def play_round_while(ground, fun) do
      play_round_while(ground, [], fun)
    end

    def play_round_while(ground = %Ground{round: round}, [], fun) do
      case fun.(ground) do
        :cont ->
          play_round_while(%Ground{ground | round: round + 1}, sorted_unit_coords(ground), fun)

        {:halt, result} ->
          result
      end
    end

    def play_round_while(%Ground{} = ground, [next_turn | rest], fun) do
      ground
      |> play_turn(next_turn)
      |> play_round_while(rest, fun)
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

    def attack(ground = %Ground{map: map}, target) do
      new_map =
        case Unit.damaged(map[target], 3) do
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
    input
    |> Ground.from_raw_input()
    |> Ground.play_round_while(fn ground = %Ground{map: map, round: round} ->
      # Uncomment below to watch the process on screen
      # IO.inspect(round)
      # Ground.display(ground)

      case Enum.reduce(map, {0, 0}, fn
             {_, %Unit{kind: ?G}}, {e_count, g_count} -> {e_count, g_count + 1}
             {_, %Unit{kind: ?E}}, {e_count, g_count} -> {e_count + 1, g_count}
             _, acc -> acc
           end) do
        {e_count, g_count} when e_count == 0 or g_count == 0 ->
          {:halt, round * Ground.total_hp(ground)}

        _ ->
          :cont
      end
    end)
  end

  def part2(_input) do
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
      test "part1 result" do
        assert 27730 == Day15.part1(@input)
      end
    end

  [input, "--part1"] ->
    input
    |> File.read!()
    |> Day15.part1()
    |> IO.inspect()

  [input, "--part2"] ->
    input
    |> File.read!()
    |> Day15.part2()
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input_file]")
end
