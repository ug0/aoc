defmodule Aoc.Y2021.Day06Test do
  use ExUnit.Case

  alias Aoc.Y2021.D06

  @input "3,4,3,1,2"
  test "part1: Count lanternfish after 80 days" do
    assert D06.part1(@input) == 5934
  end

  test "part2: Count lanternfish after 256 days" do
    assert D06.part2(@input) == 26984457539
  end
end
