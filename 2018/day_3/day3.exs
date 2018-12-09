defmodule Day3 do
  def part1(claims) do
    claims
    |> inch_coords()
    |> Stream.filter(fn {_, ids} -> length(ids) > 1 end)
    |> Enum.count()
  end

  def part2(claims) do
    overlapped_ids =
      inch_coords(claims)
      |> Stream.filter(fn {_, ids} -> length(ids) > 1 end)
      |> Enum.flat_map(fn {_, ids} -> ids end)
      |> Enum.uniq()

    (all_ids(claims) -- overlapped_ids) |> hd()
  end

  def inch_coords(claims) do
    claims
    |> Stream.map(&parse_claim/1)
    |> Enum.reduce(%{}, fn [id, left, top, width, height], acc ->
      Enum.reduce(left..(left + width - 1), acc, fn x, acc ->
        Enum.reduce(top..(top + height - 1), acc, fn y, acc ->
          Map.update(acc, {x, y}, [id], &[id | &1])
        end)
      end)
    end)
  end

  def all_ids(claims) do
    claims
    |> Enum.map(&(parse_claim(&1) |> hd()))
  end

  def parse_claim(claim) do
    [nums] =
      Regex.scan(~r/^#(\d+)\s\@\s+(\d+),(\d+):\s(\d+)x(\d+)/, claim, capture: :all_but_first)

    nums |> Enum.map(&String.to_integer/1)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day3Test do
      use ExUnit.Case

      @input """
      #1 @ 1,3: 4x4
      #2 @ 3,1: 4x4
      #3 @ 5,5: 2x2
      """
      test "part1 result" do
        assert 4 == Day3.part1(@input |> String.split("\n", trim: true))
      end

      test "part 2 result" do
        assert 3 == Day3.part2(@input |> String.split("\n", trim: true))
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.stream!()
    |> Day3.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.stream!()
    |> Day3.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
