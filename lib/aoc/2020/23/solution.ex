defmodule Aoc.Y2020.D23 do
  use Aoc.Input

  alias Aoc.Cache

  defmodule Ring do
    def new([first | _] = cups) do
      ring = Cache.new()
      Cache.put(ring, :max, 0)
      cups
      |> Stream.chunk_every(2, 1)
      |> Stream.map(fn
        [last] -> [last, first]
        pair -> pair
      end)
      |> Enum.reduce(ring, fn
        [i, j], acc ->
          acc
          |> Cache.put(i, j)
          |> Cache.put(:max, max(max(acc), i))
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
      Cache.get(ring, i)
    end

    def max(ring) do
      Cache.get(ring, :max)
    end

    def move_partial(ring, partial, current, dest) do
      ring
      |> remove_partial(current, partial)
      |> insert_partial(dest, partial)
    end

    defp insert_partial(ring, dest, [first | rest]) do
      ring
      |> Cache.put(Enum.at(rest, -1), next(ring, dest))
      |> Cache.put(dest, first)
    end

    defp remove_partial(ring, current, partial) do
      ring
      |> Cache.put(current, next(ring, Enum.at(partial, -1)))
    end
  end

  alias __MODULE__.Ring

  def part1(str \\ nil) do
    cups = (str || input()) |> String.splitter("", trim: true) |> Enum.map(&String.to_integer/1)

    Enum.reduce(1..100, {hd(cups), Ring.new(cups)}, fn _, acc ->
      move(acc)
    end)
    |> elem(1)
    |> Ring.to_list(1)
    |> tl()
    |> Enum.join()
    |> IO.inspect()
  end

  @max 1_000_000
  @times 10_000_000
  def part2(str \\ nil) do
    # str = "389125467"
    cups = (str || input()) |> String.splitter("", trim: true) |> Enum.map(&String.to_integer/1)
    cups = cups ++ Enum.to_list((Enum.max(cups) + 1)..@max)

    {_, ring} =
      Enum.reduce(1..@times, {hd(cups), Ring.new(cups)}, fn _, acc ->
        move(acc)
      end)

    x = Ring.next(ring, 1) |> IO.inspect(label: :x)
    y = Ring.next(ring, x) |> IO.inspect(label: :y)

    (x * y)
    |> IO.inspect(label: :product)
  end

  defp move({current, ring}) do
    picked = pick(ring, current, 3)
    new_ring = Ring.move_partial(ring, picked, current, find_destination(ring, current - 1, picked))
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
