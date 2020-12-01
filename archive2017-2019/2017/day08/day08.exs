defmodule Day8 do
  def part1(input) do
    input
    |> parse_instructions()
    |> execute_instructions(%{})
    |> max_register_value()
  end

  @min_num -999999999
  def part2(input) do
    input
    |> parse_instructions()
    |> Enum.reduce({%{}, @min_num}, fn instruction, {registers, max_num} ->
      registers = execute_instruction(instruction, registers)

      {registers, max(max_num, max_register_value(registers))}
    end)
    |> elem(1)
  end

  defp max_register_value(registers) when map_size(registers) == 0 do
    @min_num
  end

  defp max_register_value(registers) do
    registers
    |> Map.values()
    |> Enum.max()
  end

  defp execute_instructions(instructions, initial_registers) do
    Enum.reduce(instructions, initial_registers, fn instruction, acc ->
      execute_instruction(instruction, acc)
    end)
  end

  defp execute_instruction({operation, condition}, registers) do
    if check_condition(registers, condition) do
      execute_operation(registers, operation)
    else
      registers
    end
  end

  defp check_condition(registers, {op, key, value}) do
    compare_fun(op).(
      Map.get(registers, key, 0),
      value
    )
  end

  defp compare_fun("!="), do: &(&1 != &2)
  defp compare_fun("=="), do: &(&1 == &2)
  defp compare_fun(">="), do: &(&1 >= &2)
  defp compare_fun("<="), do: &(&1 <= &2)
  defp compare_fun(">"), do: &(&1 > &2)
  defp compare_fun("<"), do: &(&1 < &2)

  defp execute_operation(registers, operation) do
    case operation do
      {"inc", key, value} -> inc_reg(registers, key, value)
      {"dec", key, value} -> dec_reg(registers, key, value)
    end
  end

  defp inc_reg(registers, key, value) do
    Map.update(registers, key, 0 + value, &(&1 + value))
  end

  defp dec_reg(registers, key, value) do
    Map.update(registers, key, 0 - value, &(&1 - value))
  end

  defp parse_instructions(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instruction/1)
  end

  defp parse_instruction(line) do
    [operation, condition] = String.split(line, " if ")

    {parse_operation(operation), parse_condition(condition)}
  end

  defp parse_operation(str) do
    parse_expression(str)
  end

  defp parse_condition(str) do
    parse_expression(str)
  end

  defp parse_expression(str) do
    [key, op, num] = String.split(str, " ")

    {op, key, String.to_integer(num)}
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day8Test do
      use ExUnit.Case

      @input """
      b inc 5 if a > 1
      a inc 1 if b < 5
      c dec -10 if a >= 1
      c inc -20 if c == 10
      """
      test "part1 result" do
        assert Day8.part1(@input) == 1
      end

      test "part2 result" do
        assert Day8.part2(@input) == 10
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day8.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day8.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
