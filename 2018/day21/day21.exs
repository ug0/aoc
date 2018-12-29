defmodule Instruction do
  use Bitwise

  # solve part1
  def execute1(_instructions, registers, {_ip_r, 28}) do
    registers
  end

  def execute1(instructions, registers, {ip_r, ip_v}) do
    case Enum.at(instructions, ip_v) do
      nil -> registers
      _next_instruction = {op, inputs, output} ->
        registers = execute_instruction(op, inputs, output, Map.put(registers, ip_r, ip_v))
        execute1(instructions, registers, {ip_r, registers[ip_r] + 1})
    end
  end

  # solve part2
  def execute2(instructions, registers, {ip_r, 28}, {break_values, last_value}) do
    new_value = registers[4]

    if MapSet.member?(break_values, new_value) do
      last_value
    else
      {op, inputs, output} = Enum.at(instructions, 28)
      registers = execute_instruction(op, inputs, output, Map.put(registers, ip_r, 28))
      execute2(instructions, registers, {ip_r, registers[ip_r] + 1}, {MapSet.put(break_values, new_value), new_value})
    end
  end

  # speed up the loop
  def execute2(instructions, registers, {ip_r, 18}, {break_values, last_value}) do
    r2 = r3 = div(registers[3], 256)
    r1 = 1
    registers = %{registers | 1 => r1, 2 => r2, 3 => r3}
    execute2(instructions, registers, {ip_r, 8}, {break_values, last_value})
  end

  def execute2(instructions, registers, {ip_r, ip_v}, {break_values, last_value}) do
    case Enum.at(instructions, ip_v) do
      nil -> registers
      _next_instruction = {op, inputs, output} ->
        registers = execute_instruction(op, inputs, output, Map.put(registers, ip_r, ip_v))
        execute2(instructions, registers, {ip_r, registers[ip_r] + 1}, {break_values, last_value})
    end
  end

  @three_letter_ops [
    "add",
    "mul",
    "ban",
    "set"
  ]
  @two_letter_ops [
    "bo",
    "gt",
    "eq"
  ]
  def execute_instruction(<<op::binary-3, i::binary-1>>, inputs, output, registers) when op in @three_letter_ops do
    %{registers | output => operate(op).(interpret(op, i, inputs, registers))}
  end

  def execute_instruction(<<op::binary-2, i_a::binary-1, i_b::binary-1>>, inputs, output, registers) when op in @two_letter_ops do
    %{registers | output => operate(op).(interpret(op, {i_a, i_b}, inputs, registers))}
  end

  defp operate("add"), do: fn {a, b} -> a + b end
  defp operate("mul"), do: fn {a, b} -> a * b end
  defp operate("ban"), do: fn {a, b} -> a &&& b end
  defp operate("bo"), do: fn {a, b} -> a ||| b end
  defp operate("set"), do: fn {a, _} -> a end
  defp operate("gt") do
    fn
      {a, b} when a > b -> 1
      _ -> 0
    end
  end
  defp operate("eq") do
    fn
      {a, b} when a == b -> 1
      _ -> 0
    end
  end

  defp interpret("set", "r", {a, b}, registers), do: {registers[a], b}
  defp interpret("set", "i", {a, b}, _registers), do: {a, b}

  defp interpret(_, {i_a, i_b}, {a, b}, registers), do: {_interpret(i_a, a, registers), _interpret(i_b, b, registers)}
  defp interpret(_, i, {a, b}, registers), do: {registers[a], _interpret(i, b, registers)}
  defp _interpret("i", n, _registers), do: n
  defp _interpret("r", n, registers), do: registers[n]
end

defmodule Day21 do
  def part1(input) do
    registers = 0..5 |> Stream.map(&{&1, 0}) |> Enum.into(%{})
    [ip_line | instruction_lines] = String.split(input, "\n", trim: true)

    instruction_lines
    |> Enum.map(&parse_instruction/1)
    |> Instruction.execute1(registers, {parse_ip(ip_line), 0})
    |> Map.fetch!(4)
  end

  def part2(input) do
    registers = 0..5 |> Stream.map(&{&1, 0}) |> Enum.into(%{})
    [ip_line | instruction_lines] = String.split(input, "\n", trim: true)

    instruction_lines
    |> Enum.map(&parse_instruction/1)
    |> Instruction.execute2(registers, {parse_ip(ip_line), 0}, {MapSet.new, nil})
  end

  defp parse_ip("#ip " <> ip), do: String.to_integer(ip)

  defp parse_instruction(line) do
    [op | rest] = line |> String.split(" ")
    [input1, input2, output] = rest |> Enum.map(&String.to_integer/1)

    {op, {input1, input2}, output}
  end
end

case System.argv() do
  [input, "--part1"] ->
    input
    |> File.read!()
    |> Day21.part1()
    |> IO.inspect()

  [input, "--part2"] ->
    input
    |> File.read!()
    |> Day21.part2()
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input_file]")
end
