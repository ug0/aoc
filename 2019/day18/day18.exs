defmodule Day18 do
  alias __MODULE__.Maze

  def part1(input) do
    input
    |> Maze.new()
    |> Maze.collect_all_keys()
    |> Map.fetch!(:moves)
    |> IO.inspect()
  end

  defmodule Maze do
    defstruct [:map, :cursor, :keys, :moves]

    def new(raw_map) do
      {map, entrance} = parse_map(raw_map)

      %__MODULE__{
        map: map,
        cursor: entrance,
        keys: [],
        moves: 0
      }
    end

    def collect_all_keys(%__MODULE__{} = maze) do
      if has_keys_left?(maze) do
        reachable_keys(maze, MapSet.new([maze.cursor]))
        |> Stream.map(fn {key, m} ->
          collect_all_keys(m)
        end)
        |> Enum.min_by(& &1.moves)
      else
        maze
      end
    end

    defp has_keys_left?(%__MODULE__{map: map}) do
      map
      |> Map.values()
      |> Enum.any?(&(&1 in ?a..?z))
    end

    defp reachable_keys(%__MODULE__{cursor: {x, y}} = maze, checked) do
      [
        {-1, 0},
        {1, 0},
        {0, -1},
        {0, 1}
      ]
      |> Stream.reject(fn {i, j} ->
        MapSet.member?(checked, {x + i, y + j})
      end)
      |> Stream.map(&move(maze, &1))
      |> Stream.filter(fn
        {:error, _} -> false
        _ -> true
      end)
      |> Enum.flat_map(fn
        {:ok, :new_key, key, new_maze} -> [{key, new_maze}]
        {:ok, new_maze} -> reachable_keys(new_maze, MapSet.put(checked, new_maze.cursor))
      end)
    end

    defp move(
           %__MODULE__{map: map, cursor: {x, y} = cursor, moves: moves, keys: keys} = maze,
           {i, j}
         ) do
      new_cursor = {x + i, y + j}
      new_moves = moves + abs(i) + abs(j)

      case map[new_cursor] do
        ?# ->
          {:error, :wall}

        ?. ->
          {:ok,
           %{
             maze
             | map: %{map | cursor => ?., new_cursor => ?@},
               moves: new_moves,
               cursor: new_cursor
           }}

        key when key in ?a..?z ->
          {:ok, :new_key, key,
           %{
             maze
             | map: %{map | cursor => ?., new_cursor => ?@},
               cursor: new_cursor,
               moves: new_moves,
               keys: [key | keys]
           }}

        door when door in ?A..?Z ->
          if has_key_for_door?(keys, door) do
            {:ok,
             %{
               maze
               | map: %{map | cursor => ?., new_cursor => ?@},
                 cursor: new_cursor,
                 moves: new_moves
             }}
          else
            {:error, {:locked, door}}
          end
      end
    end

    defp has_key_for_door?(keys, door), do: (door + 32) in keys

    defp parse_map(str) do
      str
      |> String.splitter("\n", trim: true)
      |> Stream.with_index()
      |> Stream.flat_map(fn {row, y} ->
        row
        |> to_charlist()
        |> Stream.with_index()
        |> Enum.map(fn {area, x} -> {{x, y}, area} end)
      end)
      |> Enum.reduce({%{}, nil}, fn
        {coord, ?@}, {map, _} -> {Map.put(map, coord, ?@), coord}
        {coord, area}, {map, entrance} -> {Map.put(map, coord, area), entrance}
      end)
    end

    def display(%__MODULE__{map: map, keys: keys}) do
      points = Map.keys(map)
      {max_x, _} = Enum.max_by(points, fn {x, _} -> x end)
      {_, max_y} = Enum.max_by(points, fn {_, y} -> y end)

      0..max_y
      |> Enum.each(fn y ->
        0..max_x
        |> Enum.map(fn x ->
          Map.fetch!(map, {x, y})
        end)
        |> IO.puts()
      end)

      IO.puts("Keys: #{keys}")
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day18Test do
      use ExUnit.Case

      test "part1" do
        assert Day18.part1("""
               #########
               #b.A.@.a#
               #########
               """) == 8

        assert Day18.part1("""
               ########################
               #f.D.E.e.C.b.A.@.a.B.c.#
               ######################.#
               #d.....................#
               ########################
               """) == 86

        assert Day18.part1("""
               ########################
               #...............b.C.D.f#
               #.######################
               #.....@.a.B.c.d.A.e.F.g#
               ########################
               """) == 132

        assert Day18.part1("""
               #################
               #i.G..c...e..H.p#
               ########.########
               #j.A..b...f..D.o#
               ########@########
               #k.E..a...g..B.n#
               ########.########
               #l.F..d...h..C.m#
               #################
               """) == 136

        assert Day18.part1("""
               ########################
               #@..............ac.GI.b#
               ###d#e#f################
               ###A#B#C################
               ###g#h#i################
               ########################
               """) == 81
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day18.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day18.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
