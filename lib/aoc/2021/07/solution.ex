defmodule Aoc.Y2021.D07 do
  use Aoc.Input

  def part1(str \\ nil) do
    (str || input())
    |> parse_input()
    |> minimum_cost_to_align(constant_cost_fun())
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> parse_input()
    |> minimum_cost_to_align(increasing_cost_fun())
    |> IO.inspect()
  end

  defp minimum_cost_to_align(positions, cost_fun) do
    {min, max} = Enum.min_max(positions)

    min..max
    |> Stream.map(fn pos ->
      positions |> Stream.map(&cost_fun.(&1, pos)) |> Enum.sum()
    end)
    |> Enum.min()
  end

  defp constant_cost_fun do
    fn pos1, pos2 ->
      abs(pos1 - pos2)
    end
  end

  defp increasing_cost_fun do
    fn pos1, pos2 ->
      steps = abs(pos1 - pos2) + 1
      div(steps * (steps - 1), 2)
    end
  end

  defp parse_input(str) do
    str
    |> String.trim_trailing()
    |> String.splitter(",")
    |> Enum.map(&String.to_integer/1)
  end
end
