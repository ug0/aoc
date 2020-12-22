defmodule Aoc.Y2020.Day22Test do
  use ExUnit.Case

  @input """
  Player 1:
  9
  2
  6
  3
  1

  Player 2:
  5
  8
  4
  7
  10
  """
  test "part1: calculate winner's score" do
    assert Aoc.Y2020.D22.part1(@input) == 306
  end

  test "part2: calculate winner's score" do
    assert Aoc.Y2020.D22.part2(@input) == 291
  end
end
