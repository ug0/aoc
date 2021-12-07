defmodule Aoc.Y2021.D05 do
  use Aoc.Input

  def part1(str \\ nil) do
    (str || input())
    |> parse_input()
    |> Stream.flat_map(fn
      {{x, y1}, {x, y2}} ->
        for y <- y1..y2, do: {x, y}

      {{x1, y}, {x2, y}} ->
        for x <- x1..x2, do: {x, y}

      _ ->
        []
    end)
    |> Enum.reduce(%{}, fn point, acc ->
      Map.update(acc, point, 1, &(&1 + 1))
    end)
    |> Enum.count(fn {_, count} -> count > 1 end)
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> parse_input()
    |> Stream.flat_map(fn
      {{x, y1}, {x, y2}} ->
        for y <- y1..y2, do: {x, y}

      {{x1, y}, {x2, y}} ->
        for x <- x1..x2, do: {x, y}

      {{x1, y1}, {x2, y2}} ->
        Enum.zip(x1..x2, y1..y2)
    end)
    |> Enum.reduce(%{}, fn point, acc ->
      Map.update(acc, point, 1, &(&1 + 1))
    end)
    |> Enum.count(fn {_, count} -> count > 1 end)
    |> IO.inspect()
  end

  defp parse_input(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.splitter(" -> ")
      |> Enum.map(fn point ->
        point |> String.splitter(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
      end)
      |> List.to_tuple()
    end)
  end
end
