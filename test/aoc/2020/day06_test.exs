defmodule Aoc.Y2020.Day06Test do
  use ExUnit.Case

  test "any_yes_count" do
    assert Aoc.Y2020.D06.any_yes_count(['abc']) == 3
    assert Aoc.Y2020.D06.any_yes_count(['a', 'b', 'c']) == 3
    assert Aoc.Y2020.D06.any_yes_count(['ab', 'ac']) == 3
    assert Aoc.Y2020.D06.any_yes_count(['a', 'a', 'a', 'a']) == 1
    assert Aoc.Y2020.D06.any_yes_count(['b']) == 1
  end

  test "all_yes_count" do
    assert Aoc.Y2020.D06.all_yes_count(['abc']) == 3
    assert Aoc.Y2020.D06.all_yes_count(['a', 'b', 'c']) == 0
    assert Aoc.Y2020.D06.all_yes_count(['ab', 'ac']) == 1
    assert Aoc.Y2020.D06.all_yes_count(['a', 'a', 'a', 'a']) == 1
    assert Aoc.Y2020.D06.all_yes_count(['b']) == 1
  end
end
