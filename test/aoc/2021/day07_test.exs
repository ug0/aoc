defmodule Aoc.Y2021.Day07Test do
  use ExUnit.Case

  alias Aoc.Y2021.D07

  @input "16,1,2,0,4,2,7,1,2,14"
  test "part1: Minimum fuel cost to align" do
    assert D07.part1(@input) == 37
  end

  test "part2: Minimum fuel cost to align" do
    assert D07.part2(@input) == 168
  end
end
