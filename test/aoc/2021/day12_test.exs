defmodule Aoc.Y2021.Day12Test do
  use ExUnit.Case

  alias Aoc.Y2021.D12

  @input1 """
  start-A
  start-b
  A-c
  A-b
  b-d
  A-end
  b-end
  """
  @input2 """
  dc-end
  HN-start
  start-kj
  dc-start
  dc-HN
  LN-dc
  HN-end
  kj-sa
  kj-HN
  kj-dc
  """
  @input3 """
  fs-end
  he-DX
  fs-he
  start-DX
  pj-DX
  end-zg
  zg-sl
  zg-pj
  pj-he
  RW-he
  fs-DX
  pj-RW
  zg-RW
  start-pj
  he-WI
  zg-he
  pj-fs
  start-RW
  """
  test "part1: Total paths that visit small caves at most once" do
    assert D12.part1(@input1) == 10
    assert D12.part1(@input2) == 19
    assert D12.part1(@input3) == 226
  end

  test "part1: Total paths with new rules" do
    assert D12.part2(@input1) == 36
    assert D12.part2(@input2) == 103
    assert D12.part2(@input3) == 3509
  end
end
