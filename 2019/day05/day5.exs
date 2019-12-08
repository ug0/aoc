Code.load_file("../intcode_program.exs", __DIR__)

defmodule Day5 do
  alias IntcodeProgram, as: Program

  def part1(input) do
    input
    |> parse_codes()
    |> Program.new(gen_input(1), gen_output())
    |> Program.execute()
    |> diagnostic_code()
  end

  def part2(input) do
    input
    |> parse_codes()
    |> Program.new(gen_input(5), gen_output())
    |> Program.execute()
    |> diagnostic_code()
  end

  defp diagnostic_code(program) do
    send(program.output, {:all_output, self()})
    receive do
      [code | _] -> code
    end
  end

  defp gen_input(input) do
    spawn_link(__MODULE__, :input_fun, [input])
  end

  defp gen_output do
    spawn_link(__MODULE__, :output_fun, [[]])
  end

  def input_fun(input) do
    receive do
      {:read_input, pid} -> send(pid, input)
    end
    input_fun(input)
  end

  def output_fun(values) do
    receive do
      {:write_output, v} ->
        output_fun([v | values])

      {:all_output, pid} ->
        send(pid, values)
        output_fun(values)
    end
  end

  defp parse_codes(input) do
    input
    |> String.splitter(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day5Test do
      use ExUnit.Case
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day5.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day5.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
