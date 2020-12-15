defmodule Aoc.Y2020.D15 do
  use Aoc.Input

  alias Aoc.Cache

  def part1 do
    starting_numbers()
    |> spoken_number(2020)
    |> IO.inspect()
  end

  def part2 do
    starting_numbers()
    |> spoken_number(30_000_000)
    |> IO.inspect()
  end

  def spoken_number(start_nums, final_turns) do
    [{current, turns} | history] = start_nums |> Stream.with_index(1) |> Enum.reverse()
    spoken = Cache.new()
    history |> Enum.reverse() |> Enum.each(fn {n, t} -> Cache.put(spoken, n, t) end)

    spoken_number(
      current,
      turns,
      final_turns,
      spoken
    )
  end

  defp spoken_number(current, final_turns, final_turns, _spoken) do
    current
  end

  defp spoken_number(current, turns, final_turns, spoken) do
    prev_turns = Cache.get(spoken, current) || turns
    Cache.put(spoken, current, turns)

    spoken_number(
      turns - prev_turns,
      turns + 1,
      final_turns,
      spoken
    )
  end

  defp starting_numbers do
    input()
    |> String.splitter(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
