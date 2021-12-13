defmodule Aoc.Y2021.Day10Test do
  use ExUnit.Case

  alias Aoc.Y2021.D10

  @input """
  [({(<(())[]>[[{[]{<()<>>
  [(()[<>])]({[<{<<[]>>(
  {([(<{}[<>[]}>{[]{[(<()>
  (((({<>}<{<{<>}{[]{[]{}
  [[<[([]))<([[{}[[()]]]
  [{[{({}]{}}([{[{{{}}([]
  {<[[]]>}<{[{[{[]{()[[[]
  [<(<(<(<{}))><([]([]()
  <{([([[(<>()){}]>(<<{{
  <{([{{}}[<[[[<>{}]]]>[]]
  """
  test "part1: Total syntax error score" do
    assert D10.part1(@input) == 26397
  end

  test "part2: The middle score of the completion strings" do
    assert D10.part2(@input) == 288957
  end
end
