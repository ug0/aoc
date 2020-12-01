defmodule Day3 do
  def part1(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(&wire_points/1)
    |> intersections()
    |> Stream.map(&manhattan_distance(&1, {0, 0}))
    |> Enum.min()
  end

  def part2(input) do
    wires =
      input
      |> String.splitter("\n", trim: true)
      |> Stream.map(&String.split(&1, ","))
      |> Enum.map(&wire_points/1)

    wires
    |> intersections()
    |> Stream.map(fn point ->
      wires
      |> Stream.map(&distance_to_point(&1, point))
      |> Enum.sum()
    end)
    |> Enum.min()
  end

  defp distance_to_point(wire, point) do
    Enum.find_index(wire, &(&1 == point)) + 1
  end

  defp intersections(wires) do
    wires
    |> Stream.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.intersection/2)
  end

  defp manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp wire_points(wire) do
    wire_points({0, 0}, wire, [])
  end

  defp wire_points(_cur, [], points) do
    Enum.reverse(points)
  end

  defp wire_points(cur, [next | rest], points) do
    [new_cur | _] = new_points = points_between(cur, next) |> Enum.reverse()
    wire_points(new_cur, rest, new_points ++ points)
  end

  defp points_between(point, <<direction::utf8, num::binary>>) do
    Enum.map(1..String.to_integer(num), fn i ->
      point_move(direction).(point, i)
    end)
  end

  defp point_move(?R) do
    fn {x, y}, i -> {x + i, y} end
  end

  defp point_move(?L) do
    fn {x, y}, i -> {x - i, y} end
  end

  defp point_move(?U) do
    fn {x, y}, i -> {x, y + i} end
  end

  defp point_move(?D) do
    fn {x, y}, i -> {x, y - i} end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day3Test do
      use ExUnit.Case

      test "part1 result" do
        assert Day3.part1("""
               R75,D30,R83,U83,L12,D49,R71,U7,L72
               U62,R66,U55,R34,D71,R55,D58,R83
               """) == 159

        assert Day3.part1("""
               R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
               U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
               """) == 135
      end

      test "part2 result" do
        assert Day3.part2("""
               R75,D30,R83,U83,L12,D49,R71,U7,L72
               U62,R66,U55,R34,D71,R55,D58,R83
               """) == 610

        assert Day3.part2("""
               R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
               U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
               """) == 410
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day3.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day3.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
