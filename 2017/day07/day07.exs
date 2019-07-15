defmodule Day7 do
  def part1(input) do
    rows = String.split(input, "\n", trim: true)

    rows
    |> parse_towers()
    |> towers_bottom()
  end

  def part2(input) do
    towers =
      input
      |> String.split("\n", trim: true)
      |> parse_towers()


    {{incorrect_sum, unbalanced_tower}, correct_sum,} = find_unbalanced_tower(towers)

    tower_weight(towers, unbalanced_tower) + correct_sum - incorrect_sum
  end

  defp find_unbalanced_tower(towers) do
    find_unbalanced_child(towers, towers_bottom(towers))
  end

  defp find_unbalanced_child(towers, tower) do
    find_unbalanced_child(towers, tower, nil)
  end

  defp find_unbalanced_child(towers, tower, result) do
      towers
      |> direct_children(tower)
      |> Stream.map(&{&1, tower_sum(towers, &1)})
      |> Enum.group_by(&(elem(&1, 1)))
      |> Enum.sort_by(fn {_sum, sub_towers} -> length(sub_towers) end)
      |> case do
        [{incorrect_sum, [{unbalanced_tower, _}]}, {correct_sum, _balanced_towers}] ->
          find_unbalanced_child(towers, unbalanced_tower, {{incorrect_sum, unbalanced_tower}, correct_sum})

        _ ->
          result
      end
  end

  defp direct_children(towers, tower) do
    :digraph.out_neighbours(towers, tower)
  end

  defp tower_sum(towers, tower) do
    tower_weight(towers, tower) +
      (:digraph.out_neighbours(towers, tower)
      |> Stream.map(&(tower_sum(towers, &1)))
      |> Enum.sum())
  end

  defp tower_weight(towers, tower) do
    {^tower, weight} = :digraph.vertex(towers, tower)
    weight
  end

  defp towers_bottom(towers) do
    {:yes, bottom} = :digraph_utils.arborescence_root(towers)
    bottom
  end

  defp parse_towers(rows) do
    rows
    |> Enum.map(&parse_row/1)
    |> to_tree()
  end

  defp to_tree(list) do
    tree = :digraph.new()

    Enum.each(list, fn tower -> :digraph.add_vertex(tree, tower.name, tower.weight) end)

    list
    |> Stream.filter(fn tower -> Map.has_key?(tower, :children) end)
    |> Enum.each(fn tower ->
      Enum.each(tower.children, fn child ->
        :digraph.add_edge(tree, tower.name, child)
      end)
    end)

    tree
  end

  defp parse_row(row) do
    weight_parser = fn x ->
      {num, _} = Integer.parse(x)
      num
    end

    case String.split(row, [" (", " -> "]) do
      [name, weight] -> %{name: name, weight: weight_parser.(weight)}
      [name, weight, children] -> %{name: name, weight: weight_parser.(weight), children: String.split(children, ", ")}
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day7Test do
      use ExUnit.Case

      @input """
      pbga (66)
      xhth (57)
      ebii (61)
      havc (66)
      ktlj (57)
      fwft (72) -> ktlj, cntj, xhth
      qoyq (66)
      padx (45) -> pbga, havc, qoyq
      tknk (41) -> ugml, padx, fwft
      jptl (61)
      ugml (68) -> gyxo, ebii, jptl
      gyxo (61)
      cntj (57)
      """
      test "part1 result" do
        assert Day7.part1(@input) == "tknk"
      end

      test "part2 result" do
        assert Day7.part2(@input) == 60
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day7.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day7.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
