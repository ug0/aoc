defmodule Day6 do
  @doc """
  1. 扫描 input 获得四个边界（最上、最右、最下、最左，坐标可能重复）。
  2. 依照边界筛选出 finite points, 判断一个坐标是否 infinite 的依据：
    若一个坐标(P)与四个边界交叉的任一点(Px)满足：
    坐标中的点到 Px 距离(Manhattan Distance)最近的点仅有一个且为点 P 本身,
    则点 P 为 infinite point, 否则为 finite point
  3. 求 finite points 在边界矩形内所属面积的最大值。
  """
  def part1(lines) do
    points = lines |> Enum.map(&parse_line/1)
    bounds = {top, right, bottom, left} = parse_bounds(points)

    finite_points = points |> Enum.reject(&(infinite_point?(&1, points, bounds)))

    Enum.reduce(left..right, %{}, fn x, acc ->
      Enum.reduce(top..bottom, acc, fn y, acc ->
        case one_closest_point({x, y}, points) do
          nil -> acc
          point -> if point in finite_points, do: Map.update(acc, point, 1, &(&1 + 1)), else: acc
        end
      end)
    end)
    |> Enum.max_by(fn {_, areas} -> areas end)
    |> elem(1)
  end

  def part2(lines, n) do
    points = lines |> Enum.map(&parse_line/1)
    bounds = {top, right, bottom, left} = parse_bounds(points)
  end

  defp infinite_point?(point, points) do
    infinite_point?(point, points, parse_bounds(points))
  end

  defp infinite_point?(point = {x, y}, points, {top, right, bottom, left}) do
    [
      {x, top},
      {x, bottom},
      {left, y},
      {right, y}
    ]
    |> Enum.any?(fn cross_bound_point ->
      one_closest_point(cross_bound_point, points) == point
    end)
  end

  defp parse_bounds([{x, y} | rest]), do: parse_bounds(rest, {y, x, y, x})
  defp parse_bounds([], bounds) when is_tuple(bounds), do: bounds
  defp parse_bounds([{x, y} | rest], {top, right, bottom, left}) do
    parse_bounds(rest, {min(y, top), max(x, right), max(y, bottom), min(x, left)})
  end

  defp one_closest_point(point, [next_point | rest]) do
    one_closest_point(point, rest, {next_point, manhattan_distance(point, next_point)}, false)
  end

  defp one_closest_point(_, [], {min_point, _}, _repeated = false), do: min_point
  defp one_closest_point(_, [], _, _repeated = true), do: nil
  defp one_closest_point(point, [next_point | rest], {min_point, min_distance}, repeated) do
    new_distance = manhattan_distance(point, next_point)

    cond do
      new_distance < min_distance -> one_closest_point(point, rest, {next_point, new_distance}, false)
      new_distance > min_distance -> one_closest_point(point, rest, {min_point, min_distance}, repeated)
      true -> one_closest_point(point, rest, {min_point, min_distance}, true)
    end
  end

  defp manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp parse_line(line) do
    line
    |> String.split(", ")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day6Test do
      use ExUnit.Case

      @input """
      1, 1
      1, 6
      8, 3
      3, 4
      5, 5
      8, 9
      """
      test "part1 result" do
        assert 17 == Day6.part1(@input |> String.split("\n", trim: true))
      end

      @input """
      1, 1
      3, 2
      5, 1
      1, 5
      5, 5
      3, 3
      """
      test "another part1 result" do
        assert 4 == Day6.part1(@input |> String.split("\n", trim: true))
      end

      test "part 2 result" do
        # assert 16 == Day6.part2(@input |> String.split("\n", trim: true), 32)
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Day6.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.stream!()
    |> Day6.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
