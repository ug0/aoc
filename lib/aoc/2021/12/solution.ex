defmodule Aoc.Y2021.D12 do
  use Aoc.Input

  def part1(str \\ nil) do
    (str || input())
    |> parse_input()
    |> find_all_paths("start", "end", can_revisit?(:part1))
    |> length()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> parse_input()
    |> find_all_paths("start", "end", can_revisit?(:part2))
    |> length()
    |> IO.inspect()
  end

  defp find_all_paths(graph, from, to, can_revisit?) do
    find_all_paths(graph, to, &(&1 != from and can_revisit?.(&1, &2)), [[from]], [])
  end

  defp find_all_paths(_graph, _to, _can_revisit?, [], found_paths) do
    found_paths
  end

  defp find_all_paths(graph, to, can_revisit?, [[cave | _] = checking | rest], found_paths) do
    {processing, finished} =
      graph
      |> :digraph.out_neighbours(cave)
      |> Stream.filter(&can_revisit?.(&1, checking))
      |> Enum.reduce({rest, found_paths}, fn
        ^to, {processing, finished} -> {processing, [[to | checking] | finished]}
        new_cave, {processing, finished} -> {[[new_cave | checking] | processing], finished}
      end)

    find_all_paths(graph, to, can_revisit?, processing, finished)
  end

  defp can_revisit?(:part1) do
    fn cave, visited ->
      is_big_cave?(cave) or cave not in visited
    end
  end

  defp can_revisit?(:part2) do
    fn cave, visited ->
      cond do
        is_big_cave?(cave) ->
          true

        cave in visited ->
          visited
          |> Enum.group_by(& &1)
          |> Enum.all?(fn {c, list} -> is_big_cave?(c) or length(list) < 2 end)

        true ->
          true
      end
    end
  end

  defp is_big_cave?(cave) do
    cave == String.upcase(cave)
  end

  defp parse_input(str) do
    g = :digraph.new()

    str
    |> String.splitter("\n", trim: true)
    |> Enum.each(fn line ->
      [cave1, cave2] = String.split(line, "-")
      :digraph.add_vertex(g, cave1)
      :digraph.add_vertex(g, cave2)
      :digraph.add_edge(g, cave1, cave2)
      :digraph.add_edge(g, cave2, cave1)
    end)

    g
  end
end
