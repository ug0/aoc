defmodule Aoc.Y2020.Day08Test do
  use ExUnit.Case

  @input """
  nop +0
  acc +1
  jmp +4
  acc +3
  jmp -3
  acc -99
  acc +1
  jmp -4
  acc +6
  """
  test "part1: acc value before loop" do
    assert Aoc.Y2020.D08.part1(@input) == 5
  end

  test "part2: final acc value of fixed run" do
    assert Aoc.Y2020.D08.part2(@input) == 8
  end
end
