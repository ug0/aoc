defmodule Aoc.Y2021.D09 do
  use Aoc.Input

  def part1(str \\ nil) do
    (str || input())
    |> parse_input()
    |> low_points()
    |> Stream.map(fn {_, height} -> height + 1 end)
    |> Enum.sum()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> parse_input()
    |> basins()
    |> Stream.map(&length/1)
    |> Enum.sort(:desc)
    |> Stream.take(3)
    |> Enum.reduce(&Kernel.*/2)
    |> IO.inspect()
  end

  defp low_points(heightmap) do
    Enum.filter(heightmap, fn {coord, _height} -> low_point?(heightmap, coord) end)
  end

  defp low_point?(heightmap, coord) do
    coord
    |> adjacent_locations()
    |> Enum.all?(&(heightmap[&1] > heightmap[coord]))
  end

  def basins(heightmap) do
    heightmap
    |> low_points()
    |> Enum.map(fn {coord, _height} -> detect_basin(heightmap, coord) end)
  end

  defp detect_basin(heightmap, coord) do
    detect_basin(heightmap, adjacent_locations(coord), MapSet.new([coord]))
  end

  defp detect_basin(heightmap, unchecked, checked) do
    unchecked
    |> Stream.uniq()
    |> Stream.filter(&(heightmap[&1] < 9))
    |> Enum.reject(&MapSet.member?(checked, &1))
    |> case do
      [] ->
        checked |> MapSet.to_list()

      new_checked ->
        detect_basin(
          heightmap,
          Enum.flat_map(new_checked, &adjacent_locations/1),
          MapSet.union(checked, MapSet.new(new_checked))
        )
    end
  end

  defp adjacent_locations({x, y}) do
    [
      {0, -1},
      {0, 1},
      {-1, 0},
      {1, 0}
    ]
    |> Enum.map(fn {i, j} -> {x + i, y + j} end)
  end

  defp parse_input(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> String.splitter("", trim: true)
      |> Stream.map(&String.to_integer/1)
      |> Stream.with_index()
      |> Enum.map(fn {h, x} -> {{x, y}, h} end)
    end)
    |> Enum.into(%{})
  end
end
