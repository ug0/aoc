Code.load_file("../intcode_program.exs", __DIR__)

defmodule Day21 do
  alias IntcodeProgram, as: Program

  def part1(program) do
    program
    |> Program.new(
      spawn_link(__MODULE__, :input, [work_script()]),
      spawn_link(__MODULE__, :output, [self()])
    )
    |> Program.execute()

    receive do
      {:damage, damage} -> damage
    end
  end

  def part2(program) do
    program
    |> Program.new(
      spawn_link(__MODULE__, :input, [run_script()]),
      spawn_link(__MODULE__, :output, [self()])
    )
    |> Program.execute()

    receive do
      {:damage, damage} -> damage
    end
  end

  defp work_script do
    # D and !(A and B and C)
    """
    NOT J J
    AND A J
    AND B J
    AND C J
    NOT J J
    AND D J
    WALK
    """
    |> to_charlist()
  end

  defp run_script do
    # !A or D and !(A and B and C) and !(!(E and F and G) and !H)
    # !A or D and !(A and B and C) and ((E and F and G) or H)
    """
    NOT T T
    AND A T
    AND B T
    AND C T
    NOT T T
    AND D T
    NOT J J
    AND E J
    AND F J
    AND G J
    OR H J
    AND T J
    NOT A T
    OR T J
    RUN
    """
    |> to_charlist()
  end

  def input(script) do
    receive do
      {:read_input, remote} ->
        [h | t] = script
        send(remote, h)
        input(t)
    end
  end

  def output(pid) do
    receive do
      {:write_output, damage} when damage > 128 ->
        send(pid, {:damage, damage})

      {:write_output, char} ->
        IO.write([char])
        output(pid)
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day21Test do
      use ExUnit.Case
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day21.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day21.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
