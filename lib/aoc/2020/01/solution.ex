defmodule Aoc.Y2020.D01 do
  use Aoc.Input

  @sum 2020
  def part1 do
    parsed_input()
    |> two_sum(@sum)
    |> IO.inspect()
  end

  def part2 do
    parsed_input()
    |> three_sum(@sum)
    |> IO.inspect()
  end

  def two_sum([], _sum) do
    nil
  end

  def two_sum([x | rest], sum) do
    case Enum.find(rest, &(x + &1 == sum)) do
      nil -> two_sum(rest, sum)
      y -> x * y
    end
  end

  def three_sum([x | rest], sum) do
    case two_sum(rest, sum - x) do
      nil -> three_sum(rest, sum)
      y -> x * y
    end
  end

  defp parsed_input do
    input()
    |> String.splitter("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
