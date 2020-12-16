defmodule Aoc.Y2020.Day16Test do
  use ExUnit.Case

  @input """
  class: 1-3 or 5-7
  row: 6-11 or 33-44
  seat: 13-40 or 45-50

  your ticket:
  7,1,14

  nearby tickets:
  7,3,47
  40,4,50
  55,2,20
  38,6,12
  """
  test "part1: scanning error rate" do
    assert Aoc.Y2020.D16.part1(@input) == 71
  end

  @tickets [
    [11, 12, 13],
    [3, 9, 18],
    [15, 1, 5],
    [5, 14, 9]
  ]
  @rules [
    {"class", [0..1, 4..19]},
    {"row", [0..5, 8..19]},
    {"seat", [0..13, 16..19]},
  ]
  test "part2: parse fields order" do
    assert Aoc.Y2020.D16.parse_fields_order(@rules, @tickets) == ["row", "class", "seat"]
  end
end
