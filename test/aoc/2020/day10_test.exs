defmodule Aoc.Y2020.Day10Test do
  use ExUnit.Case

  @small_input """
  16
  10
  15
  5
  1
  11
  7
  19
  6
  12
  4
  """
  @large_input """
  28
  33
  18
  42
  31
  14
  46
  20
  48
  47
  24
  23
  49
  45
  19
  38
  39
  11
  1
  32
  25
  35
  8
  17
  7
  9
  4
  2
  34
  10
  3
  """
  test "part1: 1-jolt differences multiplied by the 3-jolt differences" do
    assert Aoc.Y2020.D10.part1(@small_input) == 35
    assert Aoc.Y2020.D10.part1(@large_input) == 220
  end

  test "part2: count distinct arrangements" do
    assert Aoc.Y2020.D10.part2(@small_input) == 8
    assert Aoc.Y2020.D10.part2(@large_input) == 19208
  end
end
