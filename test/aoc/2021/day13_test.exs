defmodule Aoc.Y2021.Day13Test do
  use ExUnit.Case

  alias Aoc.Y2021.D13

  @input """
  6,10
  0,14
  9,10
  0,3
  10,4
  4,11
  6,0
  6,12
  4,1
  0,13
  10,12
  3,4
  3,0
  8,4
  1,10
  2,14
  8,10
  9,0

  fold along y=7
  fold along x=5
  """
  test "part1: Count dots after first fold" do
    assert D13.part1(@input) == 17
  end
end
