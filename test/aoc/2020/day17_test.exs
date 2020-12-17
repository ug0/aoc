defmodule Aoc.Y2020.Day17Test do
  use ExUnit.Case

  @input """
  .#.
  ..#
  ###
  """
  test "part1(3 dimension): count active state after the sixth cycle" do
    assert Aoc.Y2020.D17.part1(@input) == 112
  end

  test "part1(4 dimension): count active state after the sixth cycle" do
    assert Aoc.Y2020.D17.part2(@input) == 848
  end
end
