defmodule Aoc.Y2021.D18 do
  use Aoc.Input

  def part1(str \\ nil) do
    (str || input())
    |> parse_input()
    |> Enum.reduce(&add(&2, &1))
    |> magnitude()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    numbers = (str || input()) |> parse_input()

    for(x <- numbers, y <- numbers, x != y, do: add(x, y) |> magnitude())
    |> Enum.max()
    |> IO.inspect()
  end

  def add(pair1, pair2) do
    reduce([pair1, pair2])
  end

  def magnitude([left, right]) do
    3 * magnitude(left) + 2 * magnitude(right)
  end

  def magnitude(num) when is_integer(num) do
    num
  end

  def reduce(pair) do
    pair
    |> flatten()
    |> do_reduce()
    |> restore_pair()
  end

  defp do_reduce(list) do
    list
    |> maybe_explode()
    |> maybe_split()
    |> case do
      {:unchanged, list} -> list
      {_, list} -> do_reduce(list)
    end
  end

  defp maybe_explode(list) do
    case Enum.split_while(list, fn {depth, _} -> depth < 5 end) do
      {list, []} -> {:unchanged, list}
      {left, [{d, n1}, {d, n2} | right]} -> {:exploded, do_explode({d, n1, n2}, left, right)}
    end
  end

  defp do_explode({depth, n1, n2}, left, right) do
    Enum.reverse(add_to_head(n1, Enum.reverse(left))) ++ [{depth - 1, 0} | add_to_head(n2, right)]
  end

  defp add_to_head(_, []) do
    []
  end

  defp add_to_head(x, [{d, num} | rest]) do
    [{d, num + x} | rest]
  end

  defp maybe_split({:unchanged, list}) do
    case Enum.split_while(list, fn {_, n} -> n < 10 end) do
      {list, []} -> {:unchanged, list}
      {left, [first | right]} -> {:split, do_split(first, left, right)}
    end
  end

  defp maybe_split(list_with_state) do
    list_with_state
  end

  defp do_split({depth, num}, left, right) do
    left ++ [{depth + 1, floor(num / 2)}, {depth + 1, ceil(num / 2)} | right]
  end

  def flatten(pair) do
    flatten(pair, 0)
  end

  defp flatten([left, right], depth) do
    flatten(left, 1 + depth) ++ flatten(right, 1 + depth)
  end

  defp flatten(num, depth) when is_integer(num) do
    [{depth, num}]
  end

  def restore_pair(list) do
    restore_pair(list, [])
  end

  defp restore_pair([{0, pair}], []) do
    pair
  end

  defp restore_pair([{depth, right} | rest_list], [{depth, left} | rest_stack]) do
    restore_pair([{depth - 1, [left, right]} | rest_list], rest_stack)
  end

  defp restore_pair([next | rest_list], stack) do
    restore_pair(rest_list, [next | stack])
  end

  defp parse_input(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Enum.map(&Code.string_to_quoted!/1)
  end
end
