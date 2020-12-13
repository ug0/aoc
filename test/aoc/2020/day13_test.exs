defmodule Aoc.Y2020.Day13Test do
  use ExUnit.Case

  @input """
  939
  7,13,x,x,59,x,31,19
  """

  test "part1: calculate part1 result" do
    assert Aoc.Y2020.D13.part1(@input) == 295
  end

  test "part2: calculate part2 result" do
    assert Aoc.Y2020.D13.part2(@input) == 1068781
  end
end
