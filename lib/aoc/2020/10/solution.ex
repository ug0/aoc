defmodule Aoc.Y2020.D10 do
  use Aoc.Input

  alias Aoc.Cache

  def part1(str \\ nil) do
    %{1 => diff1, 3 => diff3} =
      (str || input())
      |> parse_input()
      |> make_chain()
      |> Enum.group_by(fn [prev, next] -> next - prev end)

    (length(diff1) * length(diff3))
    |> IO.inspect()
  end

  defp make_chain(adapters) do
    [0 | adapters]
    |> Enum.sort()
    |> Stream.chunk_every(2, 1)
    |> Stream.map(fn
      [_prev, _next] = pair -> pair
      [last] -> [last, last + 3]
    end)
  end

  def part2(str \\ nil) do
    (str || input())
    |> parse_input()
    |> build_graph()
    |> count_paths()
    |> IO.inspect()
  end

  defp count_paths(graph) do
    {min, max} = graph |> :digraph.vertices() |> Enum.min_max()
    count_paths_between(graph, min, max, Cache.new())
  end

  defp count_paths_between(_graph, from, from, _cache) do
    1
  end

  defp count_paths_between(graph, from, to, cache) do
    graph
    |> :digraph.in_neighbours(to)
    |> Stream.map(fn v ->
      Cache.with_cache(cache, {from, v}, fn -> count_paths_between(graph, from, v, cache) end)
    end)
    |> Enum.sum()
  end

  defp build_graph(adapters) do
    g = :digraph.new()
    vertices = [0 | adapters] ++ [Enum.max(adapters) + 3]
    Enum.each(vertices, &:digraph.add_vertex(g, &1))

    Enum.each(vertices, fn v ->
      vertices
      |> Stream.filter(&(&1 > v and &1 <= v + 3))
      |> Enum.each(&:digraph.add_edge(g, v, &1))
    end)
    g
  end

  defp parse_input(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
