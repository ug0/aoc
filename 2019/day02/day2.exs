Code.load_file("../intcode_program.exs", __DIR__)

defmodule Day2 do
  alias IntcodeProgram, as: Program

  def part1(input) do
    input
    |> parse_codes()
    |> Program.new(nil, nil)
    |> Program.write(1, 12)
    |> Program.write(2, 2)
    |> Program.execute()
    |> Program.read(0)
  end

  def part2(input) do
    program = input |> parse_codes() |> Program.new(nil, nil)

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

  defp parse_codes(input) do
    input
    |> String.splitter(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day2Test do
      use ExUnit.Case
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
