defmodule Aoc.Y2020.D02 do
  use Aoc.Input

  def part1 do
    parsed_input()
    |> Enum.count(fn {password, policy} -> valid_appearance_times?(password, policy) end)
    |> IO.inspect()
  end

  def part2 do
    parsed_input()
    |> Enum.count(fn {password, policy} -> valid_appearance_position?(password, policy) end)
    |> IO.inspect()
  end

  def valid_appearance_times?(str, {letter, down, up}) do
    str
    |> to_charlist()
    |> Enum.count(&(&1 == letter))
    |> Kernel.in(down..up)
  end

  def valid_appearance_position?(str, {letter, pos1, pos2}) do
    str
    |> to_charlist()
    |> Stream.with_index(1)
    |> Enum.filter(fn {_, i} -> i == pos1 or i == pos2 end)
    |> case do
      [{l, _}, {l, _}] -> false
      [{^letter, _}, _] -> true
      [_, {^letter, _}] -> true
      _ -> false
    end
  end

  defp parsed_input do
    input()
    |> String.splitter("\n", trim: true)
    |> Enum.map(fn line ->
      [range, <<letter, _::binary>>, password] = String.split(line, " ")
      [x, y] = range |> String.splitter("-") |> Enum.map(&String.to_integer/1)
      {password, {letter, x, y}}
    end)
  end
end
