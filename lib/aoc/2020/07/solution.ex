defmodule Aoc.Y2020.D07 do
  use Aoc.Input

  def part1(str \\ nil) do
    (str || input())
    |> parse_rules()
    |> capable_color_count("shiny gold")
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> parse_rules()
    |> contains_bags_count("shiny gold")
    |> IO.inspect()
  end

  def capable_color_count(rules, color) do
    [color]
    |> :digraph_utils.reaching_neighbours(rules)
    |> length()
  end

  def contains_bags_count(rules, color) do
    rules
    |> child_bags(color)
    |> Stream.map(fn {n, c} -> n + n * contains_bags_count(rules, c) end)
    |> Enum.sum()
  end

  defp child_bags(rules, color) do
    rules
    |> :digraph.out_edges(color)
    |> Stream.map(&:digraph.edge(rules, &1))
    |> Enum.map(fn {_, _, c, n} -> {n, c} end)
  end

  defp parse_rules(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Enum.map(&parse_rule/1)
    |> Enum.reduce(empty_rules(), &insert_rule(&2, &1))
  end

  defp parse_rule(str) do
    case String.split(str, " bags contain ") do
      [parent_color, "no other bags."] ->
        {parent_color, []}

      [parent_color, child_color_str] ->
        {parent_color,
         child_color_str
         |> String.splitter(", ")
         |> Enum.map(fn s ->
           [[num, color]] = Regex.scan(~r/(\d+)\s([a-z\s]+)\sbags?/, s, capture: :all_but_first)
           {String.to_integer(num), color}
         end)}
    end
  end

  defp insert_rule(rules, {parent_color, child_colors}) do
    :digraph.add_vertex(rules, parent_color)

    Enum.each(child_colors, fn {num, c} ->
      :digraph.add_vertex(rules, c)
      :digraph.add_edge(rules, parent_color, c, num)
    end)

    rules
  end

  defp empty_rules do
    :digraph.new()
  end
end
