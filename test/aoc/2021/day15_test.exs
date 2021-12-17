defmodule Aoc.Y2021.Day15Test do
  use ExUnit.Case

  alias Aoc.Y2021.D15

  @input """
  1163751742
  1381373672
  2136511328
  3694931569
  7463417111
  1319128137
  1359912421
  3125421639
  1293138521
  2311944581
  """
  test "part1: Total risk of the lowest-risk-path" do
    assert D15.part1(@input) == 40
  end

  test "part2: Total risk of the lowest-risk-path for the full map" do
    assert D15.part2(@input) == 315
  end
end
