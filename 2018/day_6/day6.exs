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
    bounds = parse_bounds(points)

    finite_points = points |> Enum.reject(&(infinite_point?(&1, points, bounds)))

    bounds
    |> points_within_bounds()
    |> Enum.reduce(%{}, fn point, acc ->
      case one_closest_point(point, points) do
        nil -> acc
        closest_point -> if closest_point in finite_points, do: Map.update(acc, closest_point, 1, &(&1 + 1)), else: acc
      end
    end)
    |> Enum.max_by(fn {_, areas} -> areas end)
    |> elem(1)
  end

  @doc """
  1. 同 part1 一样确定边界
  2. 先在边界内找到所有符合条件的点
  3. 从边界外一层开始一圈一圈依次寻找符合条件的点，当出现一圈没有任何一个符合的条件的点时，停止寻找
  """
  def part2(lines, n) do
    points = lines |> Enum.map(&parse_line/1)
    bounds = parse_bounds(points)

    bounds
    |> points_within_bounds()
    |> Enum.filter(point_filter(points, n))
    |> append_points_outside_bounds(next_outer_bounds(bounds), point_filter(points, n))
    |> Enum.count()
  end

  defp append_points_outside_bounds(result, bounds, filter) do
    case bounds
    |> bounds_points()
    |> Enum.filter(filter) do
      [] -> result
      new_points -> append_points_outside_bounds(result ++ new_points, next_outer_bounds(bounds), filter)
    end
  end

  defp bounds_points({top, right, bottom, left}) do
    (for x <- left..(right - 1), do: {x, top}) ++
    (for y <- top..(bottom - 1), do: {right, y}) ++
    (for x <- (left + 1)..right, do: {x, bottom}) ++
    (for y <- (top + 1)..bottom, do: {left, y})
  end

  defp point_filter(points, total_distance_limit) do
    fn point ->
      total_distance(point, points) < total_distance_limit
    end
  end

  defp points_within_bounds({top, right, bottom, left}) do
    Stream.flat_map(left..right, fn x ->
      Stream.map(top..bottom, fn y ->
        {x, y}
      end)
    end)
  end

  defp next_outer_bounds({top, right, bottom, left}), do: {top - 1, right + 1, bottom + 1, left - 1}

  defp total_distance(point, points) do
    points
    |> Enum.reduce(0, &(&2 + manhattan_distance(&1, point)))
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

      @input """
      1, 1
      1, 6
      8, 3
      3, 4
      5, 5
      8, 9
      """
      test "part 2 result" do
        assert 16 == Day6.part2(@input |> String.split("\n", trim: true), 32)
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
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Day6.part2(10000)
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
