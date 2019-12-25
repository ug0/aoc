Code.load_file("../intcode_program.exs", __DIR__)

defmodule Day25 do
  alias IntcodeProgram, as: Program

  def part1(program) do
    droid = spawn_link(__MODULE__, :run, [:standing_by, %{}, []])

    program
    |> Program.new(droid, droid)
    |> Program.execute()
  end

  def run(:standing_by, state, received) do
    if :lists.prefix('?dnammoC', received) do
      run(:instructing, state, next_instruction(state))
    else
      receive do
        {:write_output, value} ->
          IO.write([value])
          run(:standing_by, state, [value | received])
      end
    end
  end

  def run(:instructing, state, _instruction = []) do
    run(:standing_by, state, [])
  end

  def run(:instructing, state, [next | rest]) do
    receive do
      {:read_input, pid} ->
        send(pid, next)
        run(:instructing, state, rest)
    end
  end

  defp next_instruction(_) do
    IO.gets("")
    |> to_charlist()
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day25Test do
      use ExUnit.Case
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day25.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day25.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
