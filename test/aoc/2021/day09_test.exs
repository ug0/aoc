defmodule Aoc.Y2021.Day09Test do
  use ExUnit.Case

  alias Aoc.Y2021.D09

  @input """
  2199943210
  3987894921
  9856789892
  8767896789
  9899965678
  """
  test "part1: Sum of the risk levels" do
    assert D09.part1(@input) == 15
  end

  test "part2: Multiply three largest basins" do
    assert D09.part2(@input) == 1134
  end
end
