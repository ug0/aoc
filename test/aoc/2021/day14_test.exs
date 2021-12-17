defmodule Aoc.Y2021.Day14Test do
  use ExUnit.Case

  alias Aoc.Y2021.D14

  @input """
  NNCB

  CH -> B
  HH -> N
  CB -> H
  NH -> C
  HB -> C
  HC -> B
  HN -> C
  NN -> C
  BH -> H
  NC -> B
  NB -> B
  BN -> B
  BB -> N
  BC -> B
  CC -> N
  CN -> C
  """
  test "part1: Quantity of the most commom element and subtract the quantity of the least common element" do
    assert D14.part1(@input) == 1588
  end

  test "part2: Same calculation of part1 after 40 steps" do
    assert D14.part2(@input) == 2188189693529
  end
end
