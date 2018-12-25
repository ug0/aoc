defmodule Day16 do
  defmodule Instruction do
    use Bitwise

    def all_opcodes do
      ~W(
        addr
        addi
        mulr
        muli
        banr
        bani
        borr
        bori
        setr
        seti
        gtir
        gtri
        gtrr
        eqir
        eqri
        eqrr
      )
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
    def execute(<<op::binary-3, i::binary-1>>, inputs, output, registers) when op in @three_letter_ops do
      registers
      |> List.update_at(output, fn _ ->
        operate(op).(interpret(op, i, inputs, registers))
      end)
    end

    def execute(<<op::binary-2, i_a::binary-1, i_b::binary-1>>, inputs, output, registers) when op in @two_letter_ops do
      registers
      |> List.update_at(output, fn _ ->
        operate(op).(interpret(op, {i_a, i_b}, inputs, registers))
      end)
    end

    def operate("add"), do: fn {a, b} -> a + b end
    def operate("mul"), do: fn {a, b} -> a * b end
    def operate("ban"), do: fn {a, b} -> a &&& b end
    def operate("bo"), do: fn {a, b} -> a ||| b end
    def operate("set"), do: fn {a, _} -> a end
    def operate("gt") do
      fn
        {a, b} when a > b -> 1
        _ -> 0
      end
    end
    def operate("eq") do
      fn
        {a, b} when a == b -> 1
        _ -> 0
      end
    end

    def interpret("set", "r", {a, b}, registers), do: {Enum.at(registers, a), b}
    def interpret("set", "i", {a, b}, _registers), do: {a, b}

    def interpret(_, {i_a, i_b}, {a, b}, registers), do: {_interpret(i_a, a, registers), _interpret(i_b, b, registers)}
    def interpret(_, i, {a, b}, registers), do: {Enum.at(registers, a), _interpret(i, b, registers)}
    defp _interpret("i", n, _registers), do: n
    defp _interpret("r", n, registers), do: Enum.at(registers, n)
  end

  alias Day16.Instruction

  def part1(input) do
    input
    |> parse_input1()
    |> Enum.reduce(0, fn {regs_before, [_, input1, input2, output], regs_after}, acc ->
      case Enum.count(Instruction.all_opcodes, fn opcode ->
        Instruction.execute(opcode, {input1, input2}, output, regs_before) == regs_after
      end) do
        cnt when cnt > 2 -> acc + 1
        _ -> acc
      end
    end)
  end

  def part2() do
  end

  def parse_input1(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(fn seg ->
      [regs_before, instruction, regs_after] = String.split(seg, "\n", trim: true)

      {parse_registers(regs_before), parse_instruction(instruction), parse_registers(regs_after)}
    end)
  end

  defp parse_instruction(line) do
    line
    |> String.split(~r/[^0-9]/, trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_registers(line) do
    line
    |> String.split(~r/[^0-9]/, trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end


case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day16Test do
      use ExUnit.Case

      @input """
      Before: [3, 2, 1, 1]
      9 2 1 2
      After:  [3, 2, 2, 1]
      """
      test "part1 result" do
        assert 1 == Day16.part1(@input)
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day16.part1()
    |> IO.inspect()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day16.part2()
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
