defmodule Aoc.Y2021.D19 do
  use Aoc.Input

  def part1(str \\ nil) do
    (str || input())
    |> parse_input()
    |> align_scanners()
    |> Stream.flat_map(& &1)
    |> Stream.uniq()
    |> Enum.count()
    |> IO.inspect()
  end

  def align_scanners([base | others]) do
    align_scanners(others, [base], [])
  end

  defp align_scanners([], aligned, done) do
    aligned ++ done
  end

  defp align_scanners(todo, [next | rest] = _aligned, done) do
    {aligned, remain} =
      todo
      |> Stream.map(&align_scanner(next, &1))
      |> Enum.split_with(fn
        {:ok, _} -> true
        _ -> false
      end)

    aligned = Enum.map(aligned, &elem(&1, 1))

    align_scanners(remain, rest ++ aligned, [next | done])
  end

  # OPTIMIZE
  def align_scanner(base, target) do
    [x_range, y_range, z_range] = offset_ranges(base, target)

    target
    |> rotate_versions()
    |> Stream.flat_map(fn t ->
      for(i <- x_range, j <- y_range, k <- z_range, do: [i, j, k])
      |> Stream.map(fn vec ->
        offset(t, vec)
      end)
    end)
    |> Enum.find(&match_overlapping?(base, &1))
    |> case do
      nil -> target
      aligned -> {:ok, aligned}
    end
  end

  @least_overlaps 12
  defp match_overlapping?(base, target) do
    length(base) - length(base -- target) >= @least_overlaps
  end

  defp match_overlapping?(base, target, fun) do
    match_overlapping?(
      Enum.map(base, fun),
      Enum.map(target, fun)
    )
  end

  defp offset_ranges(base, target) do
    [
      fn [x, _, _] -> x end,
      fn [_, y, _] -> y end,
      fn [_, _, z] -> z end
    ]
    |> Enum.map(fn fun ->
      -3000..3000
      |> Enum.filter(fn n ->
        target
        |> rotate_versions()
        |> Stream.map(&offset(&1, [n, n, n]))
        |> Enum.any?(&match_overlapping?(base, &1, fun))
      end)
    end)
  end

  defp offset(coords, vec) do
    Enum.map(coords, fn coord ->
      coord |> Stream.zip(vec) |> Enum.map(fn {n, i} -> n + i end)
    end)
  end

  defp rotate_versions(coords) do
    [
      fn [x, y, z] -> [x, y, z] end,
      fn [x, y, z] -> [x, z, -y] end,
      fn [x, y, z] -> [x, -y, -z] end,
      fn [x, y, z] -> [x, -z, y] end,
      fn [x, y, z] -> [-x, -y, z] end,
      fn [x, y, z] -> [-x, z, y] end,
      fn [x, y, z] -> [-x, y, -z] end,
      fn [x, y, z] -> [-x, -z, -y] end,
      fn [x, y, z] -> [y, z, x] end,
      fn [x, y, z] -> [y, x, -z] end,
      fn [x, y, z] -> [y, -z, -x] end,
      fn [x, y, z] -> [y, -x, z] end,
      fn [x, y, z] -> [-y, x, z] end,
      fn [x, y, z] -> [-y, z, -x] end,
      fn [x, y, z] -> [-y, -x, -z] end,
      fn [x, y, z] -> [-y, -z, x] end,
      fn [x, y, z] -> [z, -x, -y] end,
      fn [x, y, z] -> [z, -y, x] end,
      fn [x, y, z] -> [z, x, y] end,
      fn [x, y, z] -> [z, y, -x] end,
      fn [x, y, z] -> [-z, y, x] end,
      fn [x, y, z] -> [-z, x, -y] end,
      fn [x, y, z] -> [-z, -y, -x] end,
      fn [x, y, z] -> [-z, -x, y] end
    ]
    |> Enum.map(fn rf ->
      Enum.map(coords, &rf.(&1))
    end)
  end

  defp parse_input(str) do
    str
    |> String.splitter("\n\n", trim: true)
    |> Stream.map(&String.split(&1, "\n", trim: true))
    |> Stream.map(&tl/1)
    |> Enum.map(fn lines ->
      lines
      |> Enum.map(fn line ->
        line |> String.splitter(",") |> Enum.map(&String.to_integer/1)
      end)
    end)
  end
end
