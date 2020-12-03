defmodule Aoc.Y2020.D03 do
  use Aoc.Input

  def part1 do
    input()
    |> get_map()
    |> count_trees()
    |> IO.inspect()
  end

  def part2 do
    map = input() |> get_map()

    [
      {1, 1},
      {3, 1},
      {5, 1},
      {7, 1},
      {1, 2}
    ]
    |> Stream.map(fn {i, j} ->
      fn {x, y} -> {x + i, y + j} end
    end)
    |> Enum.map(&count_trees(map, {0, 0}, &1))
    |> Enum.reduce(1, &Kernel.*/2)
    |> IO.inspect()
  end

  @open_square ?.
  @tree ?#

  def count_trees(map, start \\ {0, 0}, move \\ fn {x, y} -> {x + 3, y + 1} end) do
    count_trees(map, start, move, 0)
  end

  defp count_trees(map, pos, move, count) do
    case check_pos(map, pos) do
      @open_square -> count_trees(map, move.(pos), move, count)
      @tree -> count_trees(map, move.(pos), move, count + 1)
      _ -> count
    end
  end

  def get_map(str) do
    map =
      str
      |> String.splitter("\n", trim: true)
      |> Stream.with_index()
      |> Enum.reduce(%{}, fn {line, y}, map ->
        line
        |> to_charlist()
        |> Stream.with_index()
        |> Enum.reduce(map, fn {p, x}, map ->
          Map.put(map, {x, y}, p)
        end)
      end)

    {{w, _}, _} = Enum.max_by(map, fn {{x, _}, _} -> x end)
    %{map: map, width: w + 1}
  end

  defp check_pos(%{map: map, width: w}, {x, y}) do
    map[{rem(x, w), y}]
  end
end
