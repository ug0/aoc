defmodule Aoc.Y2020.D23 do
  use Aoc.Input

  defmodule Ring do
    def new([first | _] = cups) do
      ring = :digraph.new()
      :digraph.add_vertex(ring, :max, Enum.max(cups))

      cups
      |> Stream.chunk_every(2, 1)
      |> Stream.map(fn
        [last] -> [last, first]
        pair -> pair
      end)
      |> Enum.reduce(ring, fn
        [i, j], acc ->
          :digraph.add_vertex(acc, i)
          :digraph.add_vertex(acc, j)
          connect(acc, i, j)
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
      [x] = :digraph.out_neighbours(ring, i)
      x
    end

    def prev(ring, i) do
      [x] = :digraph.in_neighbours(ring, i)
      x
    end

    def max(ring) do
      {:max, max} = :digraph.vertex(ring, :max)
      max
    end

    def move_partial(ring, partial, dest) do
      ring
      |> remove_partial(partial)
      |> insert_partial(dest, partial)
    end

    defp insert_partial(ring, i, [first | rest]) do
      ring
      |> connect(Enum.at(rest, -1), next(ring, i))
      |> cut(i)
      |> connect(i, first)
    end

    defp remove_partial(ring, [first | rest]) do
      first_prev = prev(ring, first)
      last = Enum.at(rest, -1)
      last_next = next(ring, last)

      ring
      |> cut(first_prev)
      |> cut(last)
      |> connect(first_prev, last_next)
    end

    defp connect(ring, i, j) do
      :digraph.add_edge(ring, i, j)
      ring
    end

    defp cut(ring, i) do
      [edge] = :digraph.out_edges(ring, i)
      :digraph.del_edge(ring, edge)
      ring
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
