defmodule Aoc.Y2020.D05 do
  use Aoc.Input

  def part1 do
    seat_ids()
    |> Enum.max()
    |> IO.inspect()
  end

  def part2 do
    seat_ids()
    |> Enum.sort()
    |> find_seat()
    |> IO.inspect()
  end

  defp find_seat([a, b | _]) when a + 1 != b do
    a + 1
  end

  defp find_seat([_ | rest]) do
    find_seat(rest)
  end

  defp seat_ids do
    input()
    |> String.splitter("\n", trim: true)
    |> Stream.map(&get_seat/1)
    |> Stream.map(&calc_seat_id/1)
  end

  def get_seat(<<row::binary-size(7), col::binary-size(3)>>) do
    {binary_to_num(row, 0, 127), binary_to_num(col, 0, 7)}
  end

  def calc_seat_id({row, col}) do
    row * 8 + col
  end

  defp binary_to_num("", i, _) do
    i
  end

  defp binary_to_num(<<fl, rest::binary>>, i, j) when fl in [?F, ?L] do
    binary_to_num(rest, i, div(i + j, 2))
  end

  defp binary_to_num(<<br, rest::binary>>, i, j) when br in [?B, ?R] do
    binary_to_num(rest, div(i + j, 2) + 1, j)
  end
end
