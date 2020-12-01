defmodule Day11 do
  @start {:cube, [0, 0, 0]}
  def part1(input) do
    @start
    |> move(parse_directions(input))
    |> distance(@start)
  end

  def part2(input) do
    @start
    |> path(parse_directions(input))
    |> Stream.map(&distance(&1, @start))
    |> Enum.max()
  end

  defp move(pos, directions) when is_list(directions) do
    Enum.reduce(directions, pos, &neighbor(&2, &1))
  end

  defp path(pos, directions) when is_list(directions) do
    directions
    |> Enum.reduce([pos], &[neighbor(hd(&2), &1) | &2])
  end

  defp parse_directions(str) do
    str
    |> String.trim()
    |> String.split(",")
    |> Enum.map(fn
      "n" -> :n
      "ne" -> :ne
      "se" -> :se
      "s" -> :s
      "sw" -> :sw
      "nw" -> :nw
    end)
  end

  @cube_vec_map %{
    n: [0, 1, -1],
    ne: [1, 0, -1],
    se: [1, -1, 0],
    s: [0, -1, 1],
    sw: [-1, 0, 1],
    nw: [-1, 1, 0]
  }
  defp neighbor({:cube, coord}, direction) do
    {:cube, coord_add(coord, Map.fetch!(@cube_vec_map, direction))}
  end

  defp distance({:cube, coord1}, {:cube, coord2}) do
    manhattan_distance(coord1, coord2) / 2
  end

  defp coord_add(v1, v2) when length(v1) == length(v2) do
    Stream.zip(v1, v2)
    |> Enum.map(fn {a, b} -> a + b end)
  end

  defp manhattan_distance(v1, v2) do
    Stream.zip(v1, v2)
    |> Stream.map(fn {a, b} -> abs(a - b) end)
    |> Enum.sum()
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day11Test do
      use ExUnit.Case

      test "part1 result" do
        assert Day11.part1("ne,ne,ne") == 3
        assert Day11.part1("ne,ne,sw,sw") == 0
        assert Day11.part1("ne,ne,s,s") == 2
        assert Day11.part1("se,sw,se,sw,sw") == 3
      end

      test "part2 result" do
        assert Day11.part2("ne,ne,ne") == 3
        assert Day11.part2("ne,ne,sw,sw") == 2
        assert Day11.part2("ne,ne,s,s") == 2
        assert Day11.part2("se,sw,se,sw,sw") == 3
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day11.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day11.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
