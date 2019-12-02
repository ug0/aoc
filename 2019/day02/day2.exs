defmodule Day2 do
  alias __MODULE__.Program

  def part1(input) do
    input
    |> parse_input()
    |> Program.new()
    |> Program.write(1, 12)
    |> Program.write(2, 2)
    |> Program.execute()
    |> Program.read(0)
  end

  def part2(input) do
    program = input |> parse_input() |> Program.new()

    {noun, verb} =
      for(n <- 0..99, v <- 0..99, do: {n, v})
      |> Enum.find(fn {n, v} ->
        program
        |> Program.write(1, n)
        |> Program.write(2, v)
        |> Program.execute()
        |> Program.read(0)
        |> Kernel.==(19_690_720)
      end)

    100 * noun + verb
  end

  defp parse_input(input) do
    input
    |> String.splitter(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defmodule Program do
    def new(codes) do
      codes
      |> Stream.with_index()
      |> Enum.into(%{}, fn {code, i} -> {i, code} end)
    end

    def read(program, addr) do
      Map.get(program, addr)
    end

    def write(program, addr, value) do
      Map.put(program, addr, value)
    end

    def execute(program, pointer \\ 0) do
      case Program.get_instruction(program, pointer) do
        :halt -> program
        {:ok, fun} -> program |> fun.() |> execute(pointer + 4)
      end
    end

    defp get_instruction(program, addr) do
      addr..(addr + 3)
      |> Enum.map(&read(program, &1))
      |> case do
        [99 | _] -> :halt
        [op, input1, input2, output] -> {:ok, parse_instruction(op, input1, input2, output)}
      end
    end

    defp parse_instruction(op, input1, input2, output) do
      fun = parse_op(op)

      fn program ->
        write(
          program,
          output,
          fun.(read(program, input1), read(program, input2))
        )
      end
    end

    defp parse_op(1), do: &(&1 + &2)
    defp parse_op(2), do: &(&1 * &2)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day2Test do
      use ExUnit.Case

      alias Day2.Program

      test "part1 result" do
        assert %{0 => 3500} =
                 [1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50] |> Program.new() |> Program.execute()

        assert %{0 => 2} = [1, 0, 0, 0, 99] |> Program.new() |> Program.execute()
        assert %{0 => 2} = [2, 4, 4, 5, 99, 0] |> Program.new() |> Program.execute()
        assert %{0 => 30} = [1, 1, 1, 4, 99, 5, 6, 0, 99] |> Program.new() |> Program.execute()
      end

      test "part2 result" do
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day2.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day2.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
