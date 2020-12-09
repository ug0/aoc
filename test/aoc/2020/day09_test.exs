defmodule Aoc.Y2020.Day09Test do
  use ExUnit.Case

  @nums [
    35,
    20,
    15,
    25,
    47,
    40,
    62,
    55,
    65,
    95,
    102,
    117,
    150,
    182,
    127,
    219,
    299,
    277,
    309,
    576
  ]

  test "part1: find invalid num" do
    assert Aoc.Y2020.D09.find_invalid_num(@nums, 5) == 127
  end

  test "part2: find weakness" do
    assert Aoc.Y2020.D09.find_weakness(@nums, 127) == 62
  end
end
