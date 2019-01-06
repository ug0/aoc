defmodule Day25 do
  def part1(input) do
    input
    |> points_from_input()
    |> build_graph()
    |> chunk_by_constellation()
    |> length()
  end

  defp chunk_by_constellation(graph) do
    graph
    |> :digraph.vertices()
    |> Stream.map(fn point ->
      case :digraph_utils.reachable_neighbours([point], graph) do
        [] -> [point]
        points -> Enum.sort(points)
      end
    end)
    |> Enum.uniq()
  end

  defp build_graph(points) do
    graph = :digraph.new()

    _add_verticles =
      points
      |> Enum.each(& :digraph.add_vertex(graph, &1))
    _add_edges =
      points
      |> Enum.each(fn point ->
        points
        |> Stream.filter(& &1 != point && close_enough?(&1, point))
        |> Enum.each(& :digraph.add_edge(graph, point, &1))
      end)

    graph
  end

  defp manhattan_distance({a1, b1, c1, d1}, {a2, b2, c2, d2}) do
    abs(a1 - a2) + abs(b1 - b2) + abs(c1 - c2) + abs(d1 - d2)
  end

  defp close_enough?(point1, point2) do
    manhattan_distance(point1, point2) <= 3
  end

  defp points_from_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day25Test do
      use ExUnit.Case

      test "part 1 result" do
        assert Day25.part1("""
               0,0,0,0
               3,0,0,0
               0,3,0,0
               0,0,3,0
               0,0,0,3
               0,0,0,6
               9,0,0,0
               12,0,0,0
               """) == 2

        assert Day25.part1("""
               -1,2,2,0
               0,0,2,-2
               0,0,0,-2
               -1,2,0,0
               -2,-2,-2,2
               3,0,2,-1
               -1,3,2,2
               -1,0,-1,0
               0,2,1,-2
               3,0,0,0
               """) == 4

        assert Day25.part1("""
               1,-1,0,1
               2,0,-1,0
               3,2,-1,0
               0,0,3,1
               0,0,-1,-1
               2,3,-2,0
               -2,2,0,0
               2,-2,0,-1
               1,-1,0,-1
               3,2,0,2
               """) == 3

        assert Day25.part1("""
               1,-1,-1,-2
               -2,-2,0,1
               0,2,1,3
               -2,3,-2,1
               0,2,3,-2
               -1,-1,1,-2
               0,-2,-1,0
               -2,2,3,-1
               1,2,2,0
               -1,-2,0,-2
               """) == 8
      end
    end

  [input, "--part1"] ->
    input
    |> File.read!()
    |> Day25.part1()
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input_file]")
end
