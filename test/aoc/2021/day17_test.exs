defmodule Aoc.Y2021.Day17Test do
  use ExUnit.Case

  alias Aoc.Y2021.D17

  @input "target area: x=20..30, y=-10..-5"
  test "part1: The highest y position can reach" do
    assert D17.part1(@input) == 45
  end

  test "part2: The number of probes with different initial velocity can reach the area" do
    assert D17.part2(@input) == 112
  end
end
