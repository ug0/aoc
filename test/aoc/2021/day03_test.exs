defmodule Aoc.Y2021.Day03Test do
  use ExUnit.Case

  alias Aoc.Y2021.D03

  @input """
  00100
  11110
  10110
  10111
  10101
  01111
  00111
  11100
  10000
  11001
  00010
  01010
  """
  test "part1: Calculate the power consumption" do
    assert D03.part1(@input) == 198
  end

  test "part2: Calculate the life support rating" do
    assert D03.part2(@input) == 230
  end
end
