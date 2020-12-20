defmodule Aoc.Y2020.Day19Test do
  use ExUnit.Case

  @input """
  0: 4 1 5
  1: 2 3 | 3 2
  2: 4 4 | 5 5
  3: 4 5 | 5 4
  4: "a"
  5: "b"

  ababbb
  bababa
  abbbab
  aaabbb
  aaaabbb
  """

  test "part1: number of messages completely match rule 0" do
    assert Aoc.Y2020.D19.part1(@input) == 2
  end
end
