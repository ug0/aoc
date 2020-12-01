defmodule Day12 do
  def part1(input) do
    input
    |> parse_programs()
    |> connected(0)
    |> length()
  end

  def part2(input) do
    input
    |> parse_programs()
    |> groups()
    |> length()
  end

  defp groups(programs) do
    :digraph_utils.components(programs)
  end

  defp connected(programs, p) do
    :digraph_utils.reachable([p], programs)
  end

  defp parse_programs(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_program_group/1)
    |> Enum.reduce(:digraph.new(), &add_program_group(&2, &1))
  end

  defp parse_program_group(line) do
    [p, conns] = String.split(line, " <-> ")

    {
      String.to_integer(p),
      conns |> String.split(", ") |> Enum.map(&String.to_integer/1)
    }
  end

  defp add_program_group(programs, {p, conns}) do
    [p | conns]
    |> Stream.reject(&:digraph.vertex(programs, &1))
    |> Enum.each(&:digraph.add_vertex(programs, &1))

    conns
    |> Stream.each(&:digraph.add_edge(programs, &1, p))
    |> Enum.each(&:digraph.add_edge(programs, p, &1))

    programs
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day12Test do
      use ExUnit.Case

      @input """
      0 <-> 2
      1 <-> 1
      2 <-> 0, 3, 4
      3 <-> 2, 4
      4 <-> 2, 3, 6
      5 <-> 6
      6 <-> 4, 5
      """
      test "part1 result" do
        assert Day12.part1(@input) == 6
      end

      test "part2 result" do
        assert Day12.part2(@input) == 2
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day12.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day12.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
