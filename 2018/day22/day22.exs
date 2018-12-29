defmodule Cave do
  defstruct [:depth, :target, :cache]

  def new(depth, target) do
    %Cave{depth: depth, target: target, cache: :ets.new(__MODULE__, [:set, :protected])}
  end

  def total_risk_level(%Cave{target: {max_x, max_y}} = cave) do
    Enum.reduce(0..max_y, 0, fn y, acc ->
      Enum.reduce(0..max_x, acc, fn x, total ->
        total +
          case region_type(cave, {x, y}) do
            :rocky -> 0
            :wet -> 1
            :narrow -> 2
          end
      end)
    end)
  end

  def geo_index(_cave, {0, 0}), do: 0
  def geo_index(%Cave{target: target}, target), do: 0
  def geo_index(_cave, {x, 0}), do: x * 16807
  def geo_index(_cave, {0, y}), do: y * 48271

  def geo_index(cave, {x, y}), do: erosion_level(cave, {x - 1, y}) * erosion_level(cave, {x, y - 1})

  def erosion_level(cave = %Cave{cache: cache}, coord) do
    case :ets.lookup(cache, {:erosion_level, coord}) do
      [{_, level}] ->
        level

      [] ->
        level = calc_erosion_level(cave, coord)
        :ets.insert(cache, {{:erosion_level, coord}, level})
        level
    end
  end

  defp calc_erosion_level(cave = %Cave{depth: depth}, coord) do
    cave
    |> geo_index(coord)
    |> Kernel.+(depth)
    |> rem(20183)
  end

  def region_type(cave = %Cave{}, coord) do
    case cave |> erosion_level(coord) |> rem(3) do
      0 -> :rocky
      1 -> :wet
      2 -> :narrow
    end
  end
end

defmodule Day22 do
  def part1(depth, target) do
    Cave.new(depth, target) |> Cave.total_risk_level()
  end

  def parse_input(input) do
    ["depth: " <> depth, "target: " <> target] = String.split(input, "\n", trim: true)

    {String.to_integer(depth),
     target |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()}
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day22Test do
      use ExUnit.Case

      test "part 1 result" do
        assert Day22.part1(510, {10, 10}) == 114
      end
    end

  [input, "--part1"] ->
    {depth, target} = Day22.parse_input(input |> File.read!())

    Day22.part1(depth, target)
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input] [--flag]")
end
