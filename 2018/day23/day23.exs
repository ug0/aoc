defmodule Day23 do
  def part1(input) do
    bots = input |> parse_bots()

    strongest_bot = Enum.max_by(bots, fn {_, radius} -> radius end)
    Enum.count(bots, &bot_in_range?(strongest_bot, &1))
  end

  def part2(input) do
  end

  defp bot_in_range?({coord1, radius}, {coord2, _}) do
    manhattan_distance(coord1, coord2) <= radius
  end

  defp manhattan_distance({x1, y1, z1}, {x2, y2, z2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end

  defp parse_bots(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    ["pos=" <> coord, "r=" <> radius] = String.split(line, ", ")

    coord =
      coord
      |> String.split(~r/[^-0-9]/, trim: true)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()

    radius = String.to_integer(radius)

    {coord, radius}
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day23Test do
      use ExUnit.Case

      @input """
      pos=<0,0,0>, r=4
      pos=<1,0,0>, r=1
      pos=<4,0,0>, r=3
      pos=<0,2,0>, r=1
      pos=<0,5,0>, r=3
      pos=<0,0,3>, r=1
      pos=<1,1,1>, r=1
      pos=<1,1,2>, r=1
      pos=<1,3,1>, r=1
      """
      test "part 1 result" do
        assert Day23.part1(@input) == 7
      end

      @input """
      pos=<10,12,12>, r=2
      pos=<12,14,12>, r=2
      pos=<16,12,12>, r=4
      pos=<14,14,14>, r=6
      pos=<50,50,50>, r=200
      pos=<10,10,10>, r=5
      """
      test "part 2 result" do
        assert Day23.part2(@input) == 36
      end
    end

  [input, "--part1"] ->
    input
    |> File.read!()
    |> Day23.part1()
    |> IO.inspect()

  [input, "--part2"] ->
    input
    |> File.read!()
    |> Day23.part2()
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input_file]")
end
