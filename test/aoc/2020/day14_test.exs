defmodule Aoc.Y2020.Day14Test do
  use ExUnit.Case

  @input """
  mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
  mem[8] = 11
  mem[7] = 101
  mem[8] = 0
  """

  test "part1: sum of all values left in memory" do
    assert Aoc.Y2020.D14.part1(@input) == 165
  end

  @input """
  mask = 000000000000000000000000000000X1001X
  mem[42] = 100
  mask = 00000000000000000000000000000000X0XX
  mem[26] = 1
  """
  test "part2: (version 2)sum of all values left in memory" do
    assert Aoc.Y2020.D14.part2(@input) == 208
  end
end
