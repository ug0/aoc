defmodule Aoc.Y2021.D06 do
  use Aoc.Input

  def part1(str \\ nil) do
    (str || input())
    |> parse_input()
    |> group_fish()
    |> after_days(80)
    |> count_fish()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> parse_input()
    |> group_fish()
    |> after_days(256)
    |> count_fish()
    |> IO.inspect()
  end

  defp group_fish(list) do
    list
    |> Enum.group_by(& &1)
    |> Enum.into(%{}, fn {timer, group} ->
      {timer, length(group)}
    end)
  end

  defp count_fish(fish) do
    fish
    |> Map.values()
    |> Stream.filter(& &1)
    |> Enum.sum()
  end

  defp after_days(fish, 0) do
    fish
  end

  defp after_days(fish, days) do
    fish
    |> Stream.filter(fn {timer, _} -> timer > 0 end)
    |> Enum.into(%{}, fn {timer, count} -> {timer - 1, count} end)
    |> Map.merge(
      %{
        6 => fish[0],
        8 => fish[0]
      },
      fn
        _, c, nil -> c
        _, nil, c -> c
        _, c1, c2 -> c1 + c2
      end
    )
    |> after_days(days - 1)
  end

  defp parse_input(str) do
    str
    |> String.trim_trailing()
    |> String.splitter(",")
    |> Enum.map(&String.to_integer/1)
  end
end
