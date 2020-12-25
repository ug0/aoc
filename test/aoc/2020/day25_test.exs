defmodule Aoc.Y2020.Day25Test do
  use ExUnit.Case

  test "find the encryption key" do
    assert Aoc.Y2020.D25.find_encryption_key(5764801, 17807724) == 14897079
  end
end
