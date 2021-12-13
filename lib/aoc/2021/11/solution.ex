defmodule Aoc.Y2021.D11 do
  use Aoc.Input

  def part1(str \\ nil) do
    octopuses = (str || input()) |> parse_input()

    1..100
    |> Enum.reduce({octopuses, 0}, fn _, {new_octopuses, flashed_count} ->
      {new_octopuses, flashed} = iterate(new_octopuses)
      {new_octopuses, flashed_count + length(flashed)}
    end)
    |> elem(1)
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    octopuses = (str || input()) |> parse_input()

    {octopuses, 0}
    |> Stream.iterate(fn {octopuses, steps} ->
      {iterate(octopuses) |> elem(0), steps + 1}
    end)
    |> Enum.find(fn {octopuses, _steps} ->
      Enum.all?(octopuses, &(elem(&1, 1) == 0))
    end)
    |> elem(1)
    |> IO.inspect()
  end

  @flash_level 9

  defp iterate(octopuses) do
    octopuses
    |> self_increase()
    |> flash()
  end

  defp self_increase(octopuses) do
    Enum.into(octopuses, %{}, fn {coord, level} -> {coord, level + 1} end)
  end

  defp flash(octopuses) do
    flash(octopuses, flashing_points(octopuses), MapSet.new())
  end

  defp flash(octopuses, [], flashed) do
    flashed = Enum.to_list(flashed)
    reset_flashed(octopuses, flashed)
  end

  defp flash(octopuses, flashings, flashed) do
    new_octopuses =
      flashings
      |> Stream.flat_map(&adjancets/1)
      |> Stream.filter(&octopuses[&1])
      |> Enum.reduce(octopuses, fn coord, acc ->
        Map.update!(acc, coord, &(&1 + 1))
      end)

    new_flashed = MapSet.union(flashed, MapSet.new(flashings))

    flash(
      new_octopuses,
      new_octopuses |> flashing_points() |> Enum.reject(&MapSet.member?(new_flashed, &1)),
      new_flashed
    )
  end

  defp reset_flashed(octopuses, flashed) do
    {
      Enum.reduce(flashed, octopuses, &Map.put(&2, &1, 0)),
      flashed
    }
  end

  defp flashing_points(octopuses) do
    octopuses
    |> Stream.filter(fn {_, level} -> level > @flash_level end)
    |> Enum.map(&elem(&1, 0))
  end

  defp adjancets({x, y}) do
    for i <- -1..1, j <- -1..1, i != 0 or j != 0, do: {x + i, y + j}
  end

  defp parse_input(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> String.splitter("", trim: true)
      |> Stream.map(&String.to_integer/1)
      |> Stream.with_index()
      |> Enum.map(fn {level, x} -> {{x, y}, level} end)
    end)
    |> Enum.into(%{})
  end
end
