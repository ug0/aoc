defmodule Aoc.Y2020.Day11Test do
  use ExUnit.Case

  @input """
  L.LL.LL.LL
  LLLLLLL.LL
  L.L.L..L..
  LLLL.LL.LL
  L.LL.LL.LL
  L.LLLLL.LL
  ..L.L.....
  LLLLLLLLLL
  L.LLLLLL.L
  L.LLLLL.LL
  """
  test "part1: get number of seats end up occupied" do
    assert Aoc.Y2020.D11.part1(@input) == 37
  end

  test "part2: get number of seats end up occupied" do
    assert Aoc.Y2020.D11.part2(@input) == 26
  end
end
