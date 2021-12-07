defmodule Aoc.Y2021.Day05Test do
  use ExUnit.Case

  alias Aoc.Y2021.D05

  @input """
  0,9 -> 5,9
  8,0 -> 0,8
  9,4 -> 3,4
  2,2 -> 2,1
  7,0 -> 7,4
  6,4 -> 2,0
  0,9 -> 2,9
  3,4 -> 1,4
  0,0 -> 8,8
  5,5 -> 8,2
  """
  test "part1: Count points that at least two lines(horizontal and vertical) overlap" do
    assert D05.part1(@input) == 5
  end

  test "part2: Count points that at least two lines(including diagonal) overlap" do
    assert D05.part2(@input) == 12
  end
end
