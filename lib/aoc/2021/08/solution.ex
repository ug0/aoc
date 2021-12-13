defmodule Aoc.Y2021.D08 do
  @moduledoc """
  @standard_mapping %{
    "cf" => 1,
    "bcdf" => 4,
    "acf" => 7,
    "abcdefg" => 8,
    "acdeg" => 2,
    "acdfg" => 3,
    "abdfg" => 5,
    "abcefg" => 0,
    "abdefg" => 6,
    "abcdfg" => 9
  }
  """
  use Aoc.Input

  def part1(str \\ nil) do
    (str || input())
    |> parse_input()
    |> Stream.map(fn {_, output} ->
      Enum.count(output, &(String.length(&1) in [2, 3, 4, 7]))
    end)
    |> Enum.sum()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> parse_input()
    |> Stream.map(fn {patterns, output} ->
      output |> Enum.map(&decode(&1, patterns)) |> Integer.undigits()
    end)
    |> Enum.sum()
    |> IO.inspect()
  end

  defp decode(digit_str, patterns) do
    patterns
    |> decode_patterns()
    |> Map.fetch!(sort_str(digit_str))
  end

  defp decode_patterns(patterns) do
    patterns
    |> Enum.group_by(&String.length/1)
    |> decode_patterns(%{})
  end


  defp decode_patterns(%{2 => [n_1], 4 => [n_4], 3 => [n_7], 7 => [n_8]} = remain, decoded) do
    remain
    |> Map.drop([2, 4, 3, 7])
    |> decode_patterns(
      Map.merge(decoded, %{
        1 => n_1,
        4 => n_4,
        7 => n_7,
        8 => n_8
      })
    )
  end

  defp decode_patterns(%{6 => n_069} = remain, %{7 => n_7, 4 => n_4} = decoded) do
    {[n_9], n_06} = Enum.split_with(n_069, &is_subset?(n_4, &1))
    {[n_0], [n_6]} = Enum.split_with(n_06, &is_subset?(n_7, &1))

    remain
    |> Map.delete(6)
    |> decode_patterns(
      Map.merge(decoded, %{
        0 => n_0,
        6 => n_6,
        9 => n_9
      })
    )
  end

  defp decode_patterns(%{5 => n_235} = remain, %{6 => n_6, 9 => n_9} = decoded) do
    {[n_2], n_35} = Enum.split_with(n_235, &(!is_subset?(&1, n_9)))
    {[n_5], [n_3]} = Enum.split_with(n_35, &is_subset?(&1, n_6))

    remain
    |> Map.delete(5)
    |> decode_patterns(
      Map.merge(decoded, %{
        2 => n_2,
        3 => n_3,
        5 => n_5
      })
    )
  end

  defp decode_patterns(_, decoded) do
    Enum.into(decoded, %{}, fn {num, str} ->
      {sort_str(str), num}
    end)
  end

  defp sort_str(str) do
    str |> String.graphemes() |> Enum.sort() |> Enum.join()
  end

  defp is_subset?(subset_str, str) do
    String.graphemes(subset_str) -- String.graphemes(str) == []
  end

  defp parse_input(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Stream.map(fn line -> String.split(line, " | ") end)
    |> Enum.map(fn [patterns, output] ->
      {String.split(patterns, " "), String.split(output, " ")}
    end)
  end
end
