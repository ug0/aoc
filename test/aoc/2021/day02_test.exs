defmodule Aoc.Y2021.Day02Test do
  use ExUnit.Case

  alias Aoc.Y2021.D02

  @input """
  forward 5
  down 5
  forward 8
  up 3
  down 8
  forward 2
  """
  test "part1: Multiplying horizontal position and depth." do
    assert D02.part1(@input) == 150
  end

  test "part2: Multiplying horizontal position and depth." do
    assert D02.part2(@input) == 900
  end
end
