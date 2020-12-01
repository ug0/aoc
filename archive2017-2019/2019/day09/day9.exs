Code.load_file("../intcode_program.exs", __DIR__)

defmodule Day9 do
  alias IntcodeProgram, as: Program

  def part1(program) do
    run(program, 1)
  end

  def part2(program) do
    run(program, 2)
  end

  defp run(program, mode) do
    program
    |> Program.new(
      spawn_link(fn ->
        receive do
          {:read_input, pid} -> send(pid, mode)
        end
      end),
      self()
    )
    |> Program.execute()

    receive do
      {:write_output, value} -> value
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day9Test do
      use ExUnit.Case
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day9.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day9.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
