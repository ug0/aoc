defmodule Aoc.Y2020.Day21Test do
  use ExUnit.Case

  @input """
  mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
  trh fvjkl sbzzf mxmxvkd (contains dairy)
  sqjhc fvjkl (contains soy)
  sqjhc mxmxvkd sbzzf (contains fish)
  """
  test "part1: the times ingredients that can't contain allergens appear" do
    assert Aoc.Y2020.D21.part1(@input) == 5
  end

  test "part2: dangerous ingredient list" do
    assert Aoc.Y2020.D21.part2(@input) == "mxmxvkd,sqjhc,fvjkl"
  end
end
