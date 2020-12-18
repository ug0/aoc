defmodule Aoc.Y2020.Day18Test do
  use ExUnit.Case

  alias Aoc.Y2020.D18

  test "evaluate expression(ignore op priority)" do
    assert D18.evaluate_expression("1 + 2 * 3 + 4 * 5 + 6") == 71
    assert D18.evaluate_expression("1 + (2 * 3) + (4 * (5 + 6))") == 51
    assert D18.evaluate_expression("2 * 3 + (4 * 5)") == 26
    assert D18.evaluate_expression("5 + (8 * 3 + 9 + 3 * 4 * 3)") == 437
    assert D18.evaluate_expression("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") == 12240
    assert D18.evaluate_expression("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 13632
  end

  test "evaluate expression(respect op priority)" do
    assert D18.evaluate_expression("1 + 2 * 3 + 4 * 5 + 6", op_priority: true) == 231
    assert D18.evaluate_expression("1 + (2 * 3) + (4 * (5 + 6))", op_priority: true) == 51
    assert D18.evaluate_expression("2 * 3 + (4 * 5)", op_priority: true) == 46
    assert D18.evaluate_expression("5 + (8 * 3 + 9 + 3 * 4 * 3)", op_priority: true) == 1445
    assert D18.evaluate_expression("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))", op_priority: true) == 669060
    assert D18.evaluate_expression("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2", op_priority: true) == 23340
  end
end
