defmodule Aoc.Y2020.D17 do
  use Aoc.Input

  @active ?#

  def part1(str \\ nil) do
    (str || input())
    |> solve(3)
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> solve(4)
    |> IO.inspect()
  end

  defp solve(str, dimension) do
    str
    |> parse_initial_active_set()
    |> Enum.into(MapSet.new(), &expand_dimension(&1, dimension))
    |> cycle(6)
    |> MapSet.size()
  end

  defp cycle(set, 0) do
    set
  end

  defp cycle(set, times) do
    set
    |> new_active_set()
    |> cycle(times - 1)
  end

  defp new_active_set(set) do
    set
    |> Stream.flat_map(&neighbors/1)
    |> Stream.uniq()
    |> Stream.filter(&is_active_in_next_cycle?(set, &1))
    |> Enum.into(MapSet.new())
  end

  defp is_active_in_next_cycle?(set, coord) do
    case {MapSet.member?(set, coord), active_neighbors_count(set, coord)} do
      {true, c} when c in 2..3 -> true
      {true, _} -> false
      {_, 3} -> true
      _ -> false
    end
  end

  defp active_neighbors_count(set, coord) do
    coord
    |> neighbors()
    |> Enum.count(&MapSet.member?(set, &1))
  end

  defp expand_dimension(coord, dimension) do
    case tuple_size(coord) do
      ^dimension -> coord
      n when n < dimension -> coord |> Tuple.append(0) |> expand_dimension(dimension)
    end
  end

  defp neighbors({x, y, z}) do
    for i <- -1..1, j <- -1..1, k <- -1..1, i != 0 or j != 0 or k != 0 do
      {x + i, y + j, z + k}
    end
  end

  defp neighbors({x, y, z, w}) do
    for i <- -1..1, j <- -1..1, k <- -1..1, l <- -1..1, i != 0 or j != 0 or k != 0 or l != 0 do
      {x + i, y + j, z + k, w + l}
    end
  end

  defp parse_initial_active_set(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> to_charlist()
      |> Stream.with_index()
      |> Stream.filter(fn {state, _} -> state == @active end)
      |> Enum.map(fn {_, x} ->
        {x, y}
      end)
    end)
    |> Enum.into(MapSet.new())
  end
end
