defmodule Aoc.Y2020.Day23Test do
  use ExUnit.Case

  test "part1: order after 1 cup after 100 moves" do
    assert Aoc.Y2020.D23.part1("389125467") == "67384529"
  end

  test "part2: multpliy two cups that wil end up immediately clockwise of cup 1" do
    assert Aoc.Y2020.D23.part2("389125467") == 149245887792
  end
end
