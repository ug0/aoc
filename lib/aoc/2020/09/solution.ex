defmodule Aoc.Y2020.D09 do
  use Aoc.Input

  def part1 do
    input()
    |> parse_nums()
    |> find_invalid_num(25)
    |> IO.inspect()
  end

  def part2 do
    nums = input() |> parse_nums()

    find_weakness(nums, find_invalid_num(nums, 25))
    |> IO.inspect()
  end

  def find_weakness([x, y | rest], target) do
    find_weakness(rest, target, [y, x], x + y)
  end

  defp find_weakness(_nums, target, candidates, target) do
    {min, max} = Enum.min_max(candidates)
    min + max
  end

  defp find_weakness([next | rest], target, candidates, sum) when target > sum do
    find_weakness(rest, target, [next | candidates], sum + next)
  end

  defp find_weakness(nums, target, candidates, sum) do
    {new_candidates, [n]} = Enum.split(candidates, -1)
    find_weakness(nums, target, new_candidates, sum - n)
  end

  def find_invalid_num(nums, len) do
    {preamble, nums} = Enum.split(nums, len)
    find_invalid_num(nums, generate_range(preamble), preamble)
  end

  def find_invalid_num([next | rest], range, [h | t]) do
    if valid_num?(range, next) do
      find_invalid_num(rest, update_range(range, h, next), t ++ [next])
    else
      next
    end
  end

  defp generate_range(premable, range \\ [])

  defp generate_range([_], range) do
    Enum.reverse(range)
  end

  defp generate_range([h | t], range) do
    generate_range(
      t,
      [Enum.map(t, &(&1 + h)) | range]
    )
  end

  defp update_range([h | t], to_remove, to_add) do
    [Enum.map(h, &(&1 - to_remove + to_add)), t ++ [[]]]
    |> List.zip()
    |> Enum.map(fn {new, l} -> l ++ [new] end)
  end

  defp valid_num?(range, num) do
    Enum.any?(range, &(num in &1))
  end

  defp parse_nums(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
