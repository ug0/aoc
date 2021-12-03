defmodule Aoc.Y2021.Day01Test do
  use ExUnit.Case

  alias Aoc.Y2021.D01

  @input [
    199,
    200,
    208,
    210,
    200,
    207,
    240,
    269,
    260,
    263
  ]
  test "part1: Count the number of measurements that are larger than the previous measurement." do
    assert D01.part1(@input) == 7
  end

  test "part2: Count the number of three-measurement that are larger than the previous measurement." do
    assert D01.part2(@input) == 5
  end
end
