defmodule Day6 do
  alias __MODULE__.OrbitMap

  def part1(input) do
    input
    |> OrbitMap.parse()
    |> OrbitMap.total_orbits()
  end

  def part2(input) do
    input
    |> OrbitMap.parse()
    |> OrbitMap.path_between("YOU", "SAN")
    |> length()
    |> Kernel.-(2)
  end

  defmodule OrbitMap do
    def parse(raw_input) do
      map = :digraph.new()

      raw_input
      |> String.splitter("\n", trim: true)
      |> Stream.map(&String.split(&1, ")"))
      |> Enum.each(fn [object, around_by] ->
        :digraph.add_vertex(map, object)
        :digraph.add_vertex(map, around_by)
        :digraph.add_edge(map, around_by, object)
      end)

      map
    end

    def path_between(map, a, b) do
      {fork_to_a, fork_to_b} = remove_common_path(center_to_object(map, a), center_to_object(map, b))

      Enum.reverse(fork_to_a) ++ fork_to_b
    end

    defp remove_common_path([h | t1], [h | t2]) do
      remove_common_path(t1, t2)
    end

    defp remove_common_path(path1, path2) do
      {path1, path2}
    end

    def objects(map) do
      :digraph.vertices(map)
    end

    def total_orbits(map) do
      map
      |> objects()
      |> Stream.map(&object_orbits(map, &1))
      |> Stream.map(&length/1)
      |> Enum.sum()
    end

    def object_orbits(map, object) do
      map
      |> object_to_center(object)
      |> Stream.filter(&(&1 != object))
      |> Enum.map(&{&1, object})
    end

    @center "COM"
    defp object_to_center(map, object) do
      :digraph.get_path(map, object, @center) || []
    end

    defp center_to_object(map, object) do
      map |> object_to_center(object) |> Enum.reverse()
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day6Test do
      use ExUnit.Case

      @input """
      COM)B
      B)C
      C)D
      D)E
      E)F
      B)G
      G)H
      D)I
      E)J
      J)K
      K)L
      """

      test "part1" do
        assert Day6.part1(@input) == 42
      end

      @input """
      COM)B
      B)C
      C)D
      D)E
      E)F
      B)G
      G)H
      D)I
      E)J
      J)K
      K)L
      K)YOU
      I)SAN
      """
      test "part2" do
        assert Day6.part2(@input) == 4
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day6.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day6.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
