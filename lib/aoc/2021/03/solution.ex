defmodule Aoc.Y2021.D03 do
  use Aoc.Input

  def part1(str \\ nil) do
    gamma_rate =
      (str || input())
      |> parse_input()
      |> calc_gamma_rate()

    epsilon_rate =
      gamma_rate
      |> Enum.map(fn
        0 -> 1
        1 -> 0
      end)

    (Integer.undigits(gamma_rate, 2) * Integer.undigits(epsilon_rate, 2))
    |> IO.inspect()
  end

  defp calc_gamma_rate(list_of_digits) do
    list_of_digits
    |> Stream.zip()
    |> Stream.map(&Tuple.to_list/1)
    |> Enum.map(fn digits ->
      {digit, _} =
        digits
        |> Enum.group_by(& &1)
        |> Enum.max_by(fn {_, list} -> length(list) end)

      digit
    end)
  end

  def part2(str \\ nil) do
    list_of_digits = parse_input(str || input())

    oxygen_rating = reduce_by_most_common_digit(list_of_digits)
    co2_rating = reduce_by_least_common_digit(list_of_digits)

    (Integer.undigits(oxygen_rating, 2) * Integer.undigits(co2_rating, 2))
    |> IO.inspect()
  end

  defp reduce_by_most_common_digit(list) do
    reduce_by_digit(list, 0, :most_common)
  end

  defp reduce_by_least_common_digit(list) do
    reduce_by_digit(list, 0, :least_common)
  end

  defp reduce_by_digit([last], _, _) do
    last
  end

  defp reduce_by_digit(list, i, strategy) do
    {group1, group2} = Enum.split_with(list, &(Enum.at(&1, i) == 0))

    [group1, group2]
    |> Enum.sort_by(&length/1)
    |> select_fun(strategy).()
    |> reduce_by_digit(i + 1, strategy)
  end

  defp select_fun(:most_common), do: &List.last/1
  defp select_fun(:least_common), do: &List.first/1

  defp parse_input(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.splitter("", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
