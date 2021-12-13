defmodule Aoc.Y2021.D10 do
  use Aoc.Input

  def part1(str \\ nil) do
    (str || input())
    |> parse_input()
    |> Stream.map(&check_syntax/1)
    |> Stream.map(fn
      {:corrupted, ")"} -> 3
      {:corrupted, "]"} -> 57
      {:corrupted, "}"} -> 1197
      {:corrupted, ">"} -> 25137
      _ -> 0
    end)
    |> Enum.sum()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> parse_input()
    |> Stream.map(&check_syntax/1)
    |> Stream.filter(fn {status, _} -> status == :incomplete end)
    |> Stream.map(fn {_, remain_openings} ->
      completion_score(remain_openings)
    end)
    |> Enum.sort()
    |> middle()
    |> IO.inspect()
  end

  defp check_syntax(chunks) do
    check_syntax(chunks, [])
  end

  defp check_syntax([], stack) do
    {:incomplete, stack}
  end

  @openings ["(", "[", "{", "<"]
  defp check_syntax([opening | remain], stack) when opening in @openings do
    check_syntax(remain, [opening | stack])
  end

  @mapping %{
    "(" => ")",
    "[" => "]",
    "{" => "}",
    "<" => ">"
  }
  defp check_syntax([closing | remain], [opening | stack]) do
    case {closing, @mapping[opening]} do
      {expect, expect} -> check_syntax(remain, stack)
      {actual, _expect} -> {:corrupted, actual}
    end
  end

  @point %{
    "(" => 1,
    "[" => 2,
    "{" => 3,
    "<" => 4
  }
  defp completion_score(openings) do
    Enum.reduce(openings, 0, fn opening, total ->
      total * 5 + @point[opening]
    end)
  end

  defp middle(list) do
    Enum.at(list, div(length(list), 2))
  end

  defp parse_input(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end
end
