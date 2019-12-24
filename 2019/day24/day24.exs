defmodule Day24 do
  def part1(str) do
    grid = parse_grid(str)

    grid
    |> Stream.iterate(&iterate/1)
    |> Enum.reduce_while(MapSet.new(), fn version, seen ->
      if MapSet.member?(seen, version) do
        {:halt, biodiversity_rating(version)}
      else
        {:cont, MapSet.put(seen, version)}
      end
    end)
  end

  def biodiversity_rating(grid) do
    grid
    |> Enum.sort_by(fn {{x, y}, _} -> {y, x} end)
    |> Stream.map(&elem(&1, 1))
    |> Enum.reduce({0, 1}, fn
      ?., {rating, weight} -> {rating, weight * 2}
      ?#, {rating, weight} -> {rating + weight, weight * 2}
    end)
    |> elem(0)
  end

  def iterate(grid) do
    grid
    |> Stream.map(fn {coord, _tile} -> {coord, next_tile_state(grid, coord)} end)
    |> Enum.into(%{})
  end

  defp next_tile_state(grid, coord) do
    case {Map.fetch!(grid, coord), around_bugs_count(grid, coord)} do
      {?#, 1} -> ?#
      {?#, _} -> ?.
      {?., 1} -> ?#
      {?., 2} -> ?#
      {tile, _} -> tile
    end
  end

  defp around_bugs_count(grid, coord) do
    grid
    |> adjacents(coord)
    |> Enum.count(fn {_, tile} -> tile == ?# end)
  end

  defp adjacents(grid, {x, y}) do
    [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1}
    ]
    |> Stream.map(&{&1, Map.get(grid, &1, ?.)})
  end

  alias __MODULE__.RecursiveGrid

  def part2(str, minutes \\ 200) do
    str
    |> parse_grid()
    |> RecursiveGrid.new()
    |> RecursiveGrid.iterate(minutes)
    |> RecursiveGrid.total_bugs()
  end

  def parse_grid(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Stream.with_index(1)
    |> Stream.flat_map(fn {row, y} ->
      row
      |> to_charlist()
      |> Stream.with_index(1)
      |> Enum.map(fn {tile, x} ->
        {{x, y}, tile}
      end)
    end)
    |> Enum.into(%{})
  end

  defmodule RecursiveGrid do
    def new(grid) do
      %{0 => grid}
    end

    def iterate(grids, minutes) do
      grids
      |> Stream.iterate(&iterate/1)
      |> Enum.at(minutes)
    end

    def iterate(grids) do
      {{min_level, _}, {max_level, _}} = Enum.min_max_by(grids, &elem(&1, 0))

      [
        {max_level + 1, next_grid_at_level(grids, max_level + 1)},
        {min_level - 1, next_grid_at_level(grids, min_level - 1)}
      ]
      |> Stream.filter(fn {_level, grid} -> bugs_count(grid) > 0 end)
      |> Enum.reduce(
        grids
        |> Stream.map(fn {level, _} -> {level, next_grid_at_level(grids, level)} end)
        |> Enum.into(%{}),
        fn {extended_level, extended_grid}, grids ->
          Map.put(grids, extended_level, extended_grid)
        end
      )
    end

    def total_bugs(grids) do
      grids
      |> Stream.map(fn {_level, grid} -> bugs_count(grid) end)
      |> Enum.sum()
    end

    defp bugs_count(grid) do
      Enum.count(grid, &(elem(&1, 1) == ?#))
    end

    defp next_grid_at_level(grids, level) do
      grids
      |> Map.get(level, empty_grid())
      |> Stream.map(fn
        {{3, 3}, _} -> {{3, 3}, ??}
        {coord, tile} -> {coord, next_tile_state(grids, level, coord, tile)}
      end)
      |> Enum.into(%{})
    end

    defp next_tile_state(grids, level, coord, tile) do
      case {tile, around_bugs_count(grids, level, coord)} do
        {?#, 1} -> ?#
        {?#, _} -> ?.
        {?., 1} -> ?#
        {?., 2} -> ?#
        {tile, _} -> tile
      end
    end

    defp around_bugs_count(grids, level, coord) do
      grids
      |> adjacents(level, coord)
      |> Enum.count(fn {_, tile} -> tile == ?# end)
    end

    defp adjacents(grids, level, {x, y} = coord) do
      [
        {x + 1, y},
        {x - 1, y},
        {x, y + 1},
        {x, y - 1}
      ]
      |> Enum.flat_map(fn
        {3, 3} -> inner_adjacents(grids, level, coord)
        {x, _} when x in [0, 6] -> outer_adjacents(grids, level, coord)
        {x, y} when x in 2..4 and y in [0, 6] -> outer_adjacents(grids, level, coord)
        c -> [{c, get_in(grids, [level, c])}]
      end)
    end

    defp inner_adjacents(grids, level, coord) do
      case coord do
        {3, 2} -> Enum.map(1..5, &{&1, 1})
        {3, 4} -> Enum.map(1..5, &{&1, 5})
        {2, 3} -> Enum.map(1..5, &{1, &1})
        {4, 3} -> Enum.map(1..5, &{5, &1})
      end
      |> Enum.map(fn coord ->
        {{level + 1, coord}, get_in(grids, [level + 1, coord])}
      end)
    end

    defp outer_adjacents(grids, level, coord) do
      case coord do
        {1, 1} -> [{3, 2}, {2, 3}]
        {5, 1} -> [{3, 2}, {4, 3}]
        {1, 5} -> [{2, 3}, {3, 4}]
        {5, 5} -> [{4, 3}, {3, 4}]
        {_x, 1} -> [{3, 2}]
        {_x, 5} -> [{3, 4}]
        {1, _y} -> [{2, 3}]
        {5, _y} -> [{4, 3}]
      end
      |> Enum.map(fn coord ->
        {{level - 1, coord}, get_in(grids, [level - 1, coord])}
      end)
    end

    defp empty_grid do
      for i <- 1..5, j <- 1..5, into: %{}, do: {{i, j}, ?.}
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day24Test do
      use ExUnit.Case

      @input """
      ....#
      #..#.
      #..##
      ..#..
      #....
      """
      test "part1" do
        assert Day24.part1(@input) == 2_129_920
      end

      test "part2" do
        assert Day24.part2(@input, 10) == 99
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day24.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day24.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
