defmodule Aoc.Y2020.Day15Test do
  use ExUnit.Case

  test "part1: find the spoken number" do
    assert Aoc.Y2020.D15.spoken_number([0,3,6], 2020) == 436
    assert Aoc.Y2020.D15.spoken_number([1,3,2], 2020) == 1
    assert Aoc.Y2020.D15.spoken_number([2,1,3], 2020) == 10
    assert Aoc.Y2020.D15.spoken_number([1,2,3], 2020) == 27
    assert Aoc.Y2020.D15.spoken_number([2,3,1], 2020) == 78
    assert Aoc.Y2020.D15.spoken_number([3,2,1], 2020) == 438
    assert Aoc.Y2020.D15.spoken_number([3,1,2], 2020) == 1836
  end

  # take several seconds for each run
  test "part2: find the spoken number after much more turns" do
    # assert Aoc.Y2020.D15.spoken_number([0,3,6], 30000000) == 175594
    # assert Aoc.Y2020.D15.spoken_number([1,3,2], 30000000) == 2578
    # assert Aoc.Y2020.D15.spoken_number([2,1,3], 30000000) == 3544142
    # assert Aoc.Y2020.D15.spoken_number([1,2,3], 30000000) == 261214
    # assert Aoc.Y2020.D15.spoken_number([2,3,1], 30000000) == 6895259
    # assert Aoc.Y2020.D15.spoken_number([3,2,1], 30000000) == 18
    # assert Aoc.Y2020.D15.spoken_number([3,1,2], 30000000) == 362
  end
end
