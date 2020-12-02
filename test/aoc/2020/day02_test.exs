defmodule Aoc.Y2020.Day02Test do
  use ExUnit.Case

  test "valid appearance times" do
    assert Aoc.Y2020.D02.valid_appearance_times?("abcde", {?a, 1, 3})
    refute Aoc.Y2020.D02.valid_appearance_times?("cdefg", {?b, 1, 3})
    assert Aoc.Y2020.D02.valid_appearance_times?("ccccccccc", {?c, 2, 9})
  end

  test "valid appearance position" do
    assert Aoc.Y2020.D02.valid_appearance_position?("abcde", {?a, 1, 3})
    refute Aoc.Y2020.D02.valid_appearance_position?("cdefg", {?b, 1, 3})
    refute Aoc.Y2020.D02.valid_appearance_position?("ccccccccc", {?c, 2, 9})
  end
end
