defmodule Aoc.Y2020.D13 do
  use Aoc.Input

  def part1(str \\ nil) do
    {arrive_at, bus_ids} = (str || input()) |> parse_input()

    {bus_id, minutes} =
      bus_ids
      |> Stream.reject(&is_nil/1)
      |> Stream.map(&{&1, waiting_minutes(&1, arrive_at)})
      |> Enum.min_by(&elem(&1, 1))

    (bus_id * minutes) |> IO.inspect()
  end

  defp waiting_minutes(bus_id, arrive_at) do
    case bus_id - rem(arrive_at, bus_id) do
      ^bus_id -> 0
      minutes -> minutes
    end
  end

  def part2(str \\ nil) do
    {_, bus_ids} = (str || input()) |> parse_input()

    bus_ids
    |> Stream.with_index()
    |> Enum.reject(fn {id, _} -> is_nil(id) end)
    |> find_earliest_timestamp()
    |> IO.inspect()
  end

  # based on 中国余数定理(Chinese Remainder Theorem)
  defp find_earliest_timestamp(busses) do
    m = busses |> Stream.map(&elem(&1, 0)) |> Enum.reduce(&Kernel.*/2)

    busses
    |> Stream.map(fn {id, offset} ->
      mi = div(m, id)
      (id - offset) * mi * Enum.find(1..(id - 1), &(rem(&1 * mi, id) == 1))
    end)
    |> Enum.sum()
    |> rem(m)
  end

  defp parse_input(str) do
    [arrive_at_str, bus_ids_str] = String.split(str, "\n", trim: true)

    {String.to_integer(arrive_at_str), parse_bus_ids(bus_ids_str)}
  end

  defp parse_bus_ids(str) do
    str
    |> String.splitter(",")
    |> Enum.map(fn
      "x" -> nil
      id -> String.to_integer(id)
    end)
  end
end
