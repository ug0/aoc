defmodule Day25 do
  alias __MODULE__.Machine

  def part1(input) do
    {initial_state, steps, states} = parse_input(input)

    Machine.new(initial_state, states)
    |> Machine.run(steps)
    |> Machine.checksum()
  end

  def part2(_input) do
    # no part2
  end

  defp parse_input(input) do
    [initial_state_part, steps_part, states_part] = String.split(input, "\n", parts: 3)

    {parse_initial_state(initial_state_part), parse_steps(steps_part), parse_states(states_part)}
  end

  defp parse_initial_state("Begin in state " <> state) do
    String.trim(state, ".")
  end

  defp parse_steps("Perform a diagnostic checksum after " <> steps) do
    {steps, _} = Integer.parse(steps)
    steps
  end

  defp parse_states(string) do
    string
    |> String.splitter("\n\n")
    |> Enum.into(%{}, &parse_state/1)
  end

  defp parse_state(string) do
    ["In state " <> state, clauses_part] =
      string |> String.trim() |> String.split(":\n", parts: 2)

    {state, parse_clauses(clauses_part)}
  end

  defp parse_clauses(string) do
    string
    |> String.trim()
    |> String.split("If", trim: true)
    |> Enum.into(%{}, &parse_clause/1)
  end

  defp parse_clause(string) do
    [" the current value is " <> value, instructions_part] = String.split(string, ":\n")

    {
      String.to_integer(value),
      instructions_part
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&parse_instruction/1)
    }
  end

  defp parse_instruction(string) do
    string
    |> String.trim()
    |> String.trim_trailing(".")
    |> case do
      "- Write the value " <> value -> {:write, String.to_integer(value)}
      "- Move one slot to the left" -> {:move, :left}
      "- Move one slot to the right" -> {:move, :right}
      "- Continue with state " <> state -> {:state, state}
    end
  end

  defmodule Machine do
    defstruct [:tape, :cursor, :states, :current_state]

    def new(current_state, states) do
      %__MODULE__{tape: %{}, cursor: 0, states: states, current_state: current_state}
    end

    def run(%__MODULE__{} = machine, 0) do
      machine
    end

    def run(%__MODULE__{states: states, current_state: current_state} = machine, steps) do
      states
      |> Map.fetch!(current_state)
      |> Map.fetch!(current_value(machine))
      |> Enum.reduce(machine, fn instruction, acc ->
        execute_instruction(acc, instruction)
      end)
      |> run(steps - 1)
    end

    def checksum(%__MODULE__{tape: tape}) do
      tape
      |> Map.values()
      |> Enum.sum()
    end

    def current_value(%__MODULE__{tape: tape, cursor: cursor}) do
      Map.get(tape, cursor, 0)
    end

    def write_value(%__MODULE__{tape: tape, cursor: cursor} = machine, value) do
      %{machine | tape: Map.put(tape, cursor, value)}
    end

    def move_slot_left(machine) do
      increase_cursor(machine, -1)
    end

    def move_slot_right(machine) do
      increase_cursor(machine, 1)
    end

    def set_state(%__MODULE__{} = machine, state) do
      %{machine | current_state: state}
    end

    defp increase_cursor(%__MODULE__{cursor: cursor} = machine, inc) do
      %{machine | cursor: cursor + inc}
    end

    defp execute_instruction(machine, {:write, value}) do
      write_value(machine, value)
    end

    defp execute_instruction(machine, {:move, :left}) do
      move_slot_left(machine)
    end

    defp execute_instruction(machine, {:move, :right}) do
      move_slot_right(machine)
    end

    defp execute_instruction(machine, {:state, state}) do
      set_state(machine, state)
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day25Test do
      use ExUnit.Case

      @input """
      Begin in state A.
      Perform a diagnostic checksum after 6 steps.

      In state A:
        If the current value is 0:
          - Write the value 1.
          - Move one slot to the right.
          - Continue with state B.
        If the current value is 1:
          - Write the value 0.
          - Move one slot to the left.
          - Continue with state B.

      In state B:
        If the current value is 0:
          - Write the value 1.
          - Move one slot to the left.
          - Continue with state A.
        If the current value is 1:
          - Write the value 1.
          - Move one slot to the right.
          - Continue with state A.
      """
      test "part1" do
        assert Day25.part1(@input) == 3
      end

      test "part2" do
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day25.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day25.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
