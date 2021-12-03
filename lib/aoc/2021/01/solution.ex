defmodule Aoc.Y2021.D01 do
  use Aoc.Input

  def part1(str \\ nil) do
    (str || parsed_input())
    |> Stream.chunk_every(2, 1, :discard)
    |> Enum.count(fn [prev, next] -> next > prev end)
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || parsed_input())
    |> Stream.chunk_every(3, 1, :discard)
    |> Stream.map(&Enum.sum/1)
    |> Stream.chunk_every(2, 1, :discard)
    |> Enum.count(fn [prev, next] -> next > prev end)
    |> IO.inspect()
  end

  defp parsed_input do
    input()
    |> String.splitter("\n", trim: true)
    |> Stream.map(&String.to_integer/1)
  end
end
