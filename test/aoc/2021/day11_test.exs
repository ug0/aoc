defmodule Aoc.Y2021.Day11Test do
  use ExUnit.Case

  alias Aoc.Y2021.D11

  @input """
  5483143223
  2745854711
  5264556173
  6141336146
  6357385478
  4167524645
  2176841721
  6882881134
  4846848554
  5283751526
  """
  test "part1: Total syntax error score" do
    assert D11.part1(@input) == 1656
  end

  test "part2: First step all octopuses flash" do
    assert D11.part2(@input) == 195
  end
end
