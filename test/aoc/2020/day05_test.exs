defmodule Aoc.Y2020.Day05Test do
  use ExUnit.Case

  test "get seat row and column" do
    assert Aoc.Y2020.D05.get_seat("BFFFBBFRRR") == {70, 7}
    assert Aoc.Y2020.D05.get_seat("FFFBBBFRRR") == {14, 7}
    assert Aoc.Y2020.D05.get_seat("BBFFBBFRLL") == {102, 4}
  end
end
