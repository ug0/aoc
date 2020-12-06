defmodule Aoc.Y2020.D06 do
  use Aoc.Input

  def part1 do
    groups_of_answers()
    |> Stream.map(&any_yes_count/1)
    |> Enum.sum()
    |> IO.inspect()
  end

  def part2 do
    groups_of_answers()
    |> Stream.map(&all_yes_count/1)
    |> Enum.sum()
    |> IO.inspect()
  end

  def any_yes_count(answers) do
    answers
    |> Stream.flat_map(& &1)
    |> Enum.reduce(MapSet.new(), &MapSet.put(&2, &1))
    |> MapSet.size()
  end

  def all_yes_count(answers) do
    answers
    |> Stream.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.intersection/2)
    |> MapSet.size()
  end

  defp groups_of_answers do
    input()
    |> String.splitter("\n\n", trim: true)
    |> Enum.map(fn group ->
      group |> String.split("\n", trim: true) |> Enum.map(&to_charlist/1)
    end)
  end
end
