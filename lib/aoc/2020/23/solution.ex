defmodule Aoc.Y2020.D23 do
  use Aoc.Input

  defmodule Ring do
    def new([first | _] = cups) do
      (cups ++ [first])
      |> Stream.chunk_every(2, 1, :discard)
      |> Enum.reduce(%{}, fn [i, j], acc ->
        Map.put(acc, i, j)
      end)
    end

    def to_list(ring, start) do
      to_list(ring, start, start, [start])
    end

    defp to_list(ring, stop, current, list) do
      case next(ring, current) do
        ^stop -> list |> Enum.reverse()
        new_current -> to_list(ring, stop, new_current, [new_current | list])
      end
    end

    def next(ring, i) do
      ring[i]
    end

    def prev(ring, i) do
      {k, _} = Enum.find(ring, fn {_, v} -> v == i end)
      k
    end

    def max(ring) do
      ring |> Stream.map(&elem(&1, 1)) |> Enum.max()
    end

    def move_partial(ring, partial, dest) do
      ring
      |> remove_partial(partial)
      |> insert_partial(dest, partial)
    end

    defp insert_partial(ring, i, [first | rest]) do
      ring
      |> Map.put(Enum.at(rest, -1), next(ring, i))
      |> Map.put(i, first)
    end

    defp remove_partial(ring, [first | rest]) do
      Map.put(ring, prev(ring, first), next(ring, Enum.at(rest, -1)))
    end
  end

  alias __MODULE__.Ring

  def part1(str \\ nil) do
    [current | _] =
      cups = (str || input()) |> String.splitter("", trim: true) |> Enum.map(&String.to_integer/1)

    Enum.reduce(1..100, {current, Ring.new(cups)}, fn _, acc ->
      move(acc)
    end)
    |> elem(1)
    |> Ring.to_list(1)
    |> tl()
    |> Enum.join()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
  end

  defp move({current, ring}) do
    picked = pick(ring, current, 3)
    new_ring = Ring.move_partial(ring, picked, find_destination(ring, current - 1, picked))
    {Ring.next(new_ring, current), new_ring}
  end

  defp find_destination(ring, 0, picked) do
    find_destination(ring, Ring.max(ring), picked)
  end

  defp find_destination(ring, dest, picked) do
    if dest in picked do
      find_destination(ring, dest - 1, picked)
    else
      dest
    end
  end

  defp pick(ring, pos, num) do
    pick(ring, Ring.next(ring, pos), num, [])
  end

  defp pick(_ring, _, _left = 0, picked) do
    Enum.reverse(picked)
  end

  defp pick(ring, current, left, picked) do
    pick(ring, Ring.next(ring, current), left - 1, [current | picked])
  end
end
