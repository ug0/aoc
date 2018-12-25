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

    defp interpret("set", "r", {a, b}, registers), do: {Enum.at(registers, a), b}
    defp interpret("set", "i", {a, b}, _registers), do: {a, b}

    defp interpret(_, {i_a, i_b}, {a, b}, registers), do: {_interpret(i_a, a, registers), _interpret(i_b, b, registers)}
    defp interpret(_, i, {a, b}, registers), do: {Enum.at(registers, a), _interpret(i, b, registers)}
    defp _interpret("i", n, _registers), do: n
    defp _interpret("r", n, registers), do: Enum.at(registers, n)
  end

  alias Day16.Instruction

  def part1(input) do
    input
    |> parse_input1()
    |> Enum.reduce(0, fn sample, acc ->
      case Enum.count(Instruction.all_opcodes, fn opcode ->
        sample_match_opcode?(sample, opcode)
      end) do
        cnt when cnt > 2 -> acc + 1
        _ -> acc
      end
    end)
  end

  def part2(sample, program) do
    opcode_mapping = sample |> File.read!() |> find_opcode_mapping()

    program
    |> File.read!
    |> String.splitter("\n", trim: true)
    |> Enum.reduce([0, 0, 0, 0], fn line, registers ->
      [opcode, input1, input2, output] = line |> String.splitter(" ", trim: true) |> Enum.map(&String.to_integer/1)
      Instruction.execute(opcode_mapping[opcode], {input1, input2}, output, registers)
    end)
  end

  defp find_opcode_mapping(input) do
    possible_mappings =
      input
      |> parse_input1()
      |> Enum.group_by(fn {_, [n | _], _} -> n end)
      |> Enum.map(fn {opcode_num, samples} ->
        {opcode_num, Instruction.all_opcodes
        |> Enum.filter(fn opcode ->
          Enum.all?(samples, &sample_match_opcode?(&1, opcode))
        end)}
      end)

    {mapping, []} = remove_conflicts(%{}, possible_mappings)
    mapping
  end

  defp remove_conflicts(result, possible_mapping) do
    case Enum.find(possible_mapping, fn {_, codes} -> length(codes) == 1 end) do
      {num, [code]} ->
        remove_conflicts(
          result |> Map.put(num, code),
          possible_mapping |> Stream.reject(fn {n, _} -> n == num end) |> Enum.map(fn {n, codes} -> {n, List.delete(codes, code)} end)
        )
      nil -> {result, possible_mapping}
    end
  end

  defp parse_input1(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(fn seg ->
      [regs_before, instruction, regs_after] = String.split(seg, "\n", trim: true)

      {parse_registers(regs_before), parse_instruction(instruction), parse_registers(regs_after)}
    end)
  end

  defp sample_match_opcode?({regs_before, [_, input1, input2, output], regs_after}, opcode) do
    Instruction.execute(opcode, {input1, input2}, output, regs_before) == regs_after
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

  [sample, "--part1"] ->
    sample
    |> File.read!()
    |> Day16.part1()
    |> IO.inspect()

  [sample, program, "--part2"] ->
    Day16.part2(sample, program)
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
