defmodule Aoc.Y2020.Day01Test do
  use ExUnit.Case

  @sum 2020
  @nums [1721, 979, 366, 299, 675, 1456]
  test "part1: Multiply two entries that sum to 2020" do
    assert Aoc.Y2020.D01.two_sum(@nums, @sum) == 514_579
  end

  test "part2: Multiply three entries that sum to 2020" do
    assert Aoc.Y2020.D01.three_sum(@nums, @sum) == 241_861_950
  end
end
