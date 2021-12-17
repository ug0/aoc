defmodule Aoc.Y2021.D15 do
  use Aoc.Input

  def part1(str \\ nil) do
    map = (str || input()) |> parse_input()

    {{min, _}, {max, _}} = Enum.min_max_by(map, fn {point, _} -> point end)

    map
    |> find_path(min)
    |> elem(0)
    |> Map.fetch!(max)
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    map = (str || input()) |> parse_input() |> expand()

    {{min, _}, {max, _}} = Enum.min_max_by(map, fn {point, _} -> point end)

    map
    |> find_path(min)
    |> elem(0)
    |> Map.fetch!(max)
    |> IO.inspect()
  end

  defp expand(map) do
    {{max, _}, _} = Enum.max_by(map, fn {{x, _}, _} -> x end)
    size = max + 1

    for(i <- 0..4, j <- 0..4, do: {i, j})
    |> Enum.flat_map(fn {i, j} ->
      Enum.map(map, fn {{x, y}, r} ->
        {{x + i * size, y + j * size}, inc_risk(r, i + j)}
      end)
    end)
    |> Enum.into(%{})
  end

  defp inc_risk(r, 0), do: r
  defp inc_risk(9, n), do: inc_risk(1, n - 1)
  defp inc_risk(r, n), do: inc_risk(r + 1, n - 1)

  defp find_path(map, start) do
    find_path(map, MapSet.new(), [start], %{start => 0}, %{})
  end

  defp find_path(_map, _done, _processing = [], risks, prev) do
    {risks, prev}
  end

  defp find_path(map, done, processing, risks, prev) do
    case extract_point_with_lowest_risk(processing, risks) do
      {point, rest} ->
        {risks, prev} =
          map
          |> neighbors(point)
          |> Stream.map(&{&1, map[&1]})
          |> Enum.reduce({risks, prev}, fn {neighbor, risk}, {risks, prev} ->
            update_lowest_risks_and_prev(risks, prev, point, neighbor, risk)
          end)

        new_nearby_points =
          map |> neighbors(point) |> Enum.reject(&(MapSet.member?(done, &1) or &1 in rest))

        find_path(map, MapSet.put(done, point), new_nearby_points ++ rest, risks, prev)
    end
  end

  defp extract_point_with_lowest_risk(points, risks) do
    min = Enum.min_by(points, &risks[&1])
    {min, List.delete(points, min)}
  end

  defp neighbors(map, {x, y}) do
    [
      {-1, 0},
      {1, 0},
      {0, -1},
      {0, 1}
    ]
    |> Stream.map(fn {i, j} -> {x + i, y + j} end)
    |> Enum.filter(&map[&1])
  end

  defp update_lowest_risks_and_prev(risks, prev, from, to, risk) do
    if risks[from] && risks[from] + risk < risks[to] do
      {Map.put(risks, to, risks[from] + risk), Map.put(prev, to, from)}
    else
      {risks, prev}
    end
  end

  defp parse_input(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> String.splitter("", trim: true)
      |> Stream.with_index()
      |> Enum.map(fn {r, x} -> {{x, y}, String.to_integer(r)} end)
    end)
    |> Enum.into(%{})
  end
end
