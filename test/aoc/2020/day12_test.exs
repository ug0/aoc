defmodule Aoc.Y2020.Day12Test do
  use ExUnit.Case

  @input """
  F10
  N3
  F7
  R90
  F11
  """
  test "part1: moved manhattan distance at the end of instructions" do
    assert Aoc.Y2020.D12.part1(@input) == 25
  end

  test "part2: moved manhattan distance at the end of instructions" do
    assert Aoc.Y2020.D12.part2(@input) == 286
  end
end
