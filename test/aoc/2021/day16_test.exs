defmodule Aoc.Y2021.Day16Test do
  use ExUnit.Case

  alias Aoc.Y2021.D16

  test "part1: Version sum of the packet" do
    assert D16.part1("8A004A801A8002F478") == 16
    assert D16.part1("620080001611562C8802118E34") == 12
    assert D16.part1("C0015000016115A2E0802F182340") == 23
    assert D16.part1("A0016C880162017C3686B18A3D4780") == 31
  end

  test "part2: Evaluate the packet" do
    assert D16.part2("C200B40A82") == 3
    assert D16.part2("04005AC33890") == 54
    assert D16.part2("880086C3E88112") == 7
    assert D16.part2("CE00C43D881120") == 9
    assert D16.part2("D8005AC2A8F0") == 1
    assert D16.part2("F600BC2D8F") == 0
    assert D16.part2("9C005AC2F8F0") == 0
    assert D16.part2("9C0141080250320F1802104A08") == 1
  end
end
