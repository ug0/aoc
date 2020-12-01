defmodule Day23 do
  alias __MODULE__.Program

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Program.new()
    |> start_program(fn ->
      count_command("mul")
    end)
  end

  defp count_command(cmd, count \\ 0) do
    receive do
      {:exit, _, _} -> count
      {:running, %{instructions: %{cursor: {^cmd, _args}}}} -> count_command(cmd, count + 1)
      {_, _} -> count_command(cmd, count)
    end
  end

  defp start_program(program, fun) do
    {p0, _} = spawn_monitor(&Program.init/0)
    send(p0, {:start, self(), program})
    fun.()
  end

  defmodule Program do
    defstruct registers: %{}, instructions: nil, exit: nil

    def init do
      receive do
        {:start, pid, state} -> run(state, pid)
      end
    end

    def new(instructions, registers \\ %{}) do
      %__MODULE__{
        registers: registers,
        instructions: parse_instructions(instructions)
      }
    end

    def run(%__MODULE__{exit: nil} = state, listener) do
      state
      |> report_state(listener)
      |> execute_instruction()
      |> run(listener)
    end

    def run(%__MODULE__{} = state, listener) do
      return(state, listener)
      state
    end

    defp report_state(%__MODULE__{} = state, listener) do
      send(listener, {:running, state})
      state
    end

    def return(%__MODULE__{exit: reason} = state, pid) do
      send(pid, {:exit, reason, state})
    end

    def execute_instruction(%__MODULE__{instructions: %{cursor: i}} = state) do
      state
      |> instruction_effect(i).()
      |> instruction_jump(i).()
    end

    def get_register(%__MODULE__{} = state, key) do
      Map.get(state.registers, key, 0)
    end

    def update_register(%__MODULE__{} = state, key, fun) do
      value = state |> get_register(key) |> fun.()
      Map.update!(state, :registers, &Map.put(&1, key, value))
    end

    defp instruction_effect({"set", [x, y]}) do
      fn state -> update_register(state, x, fn _ -> get_value(state, y) end) end
    end

    defp instruction_effect({"sub", [x, y]}) do
      fn state -> update_register(state, x, fn v -> v - get_value(state, y) end) end
    end

    defp instruction_effect({"mul", [x, y]}) do
      fn state -> update_register(state, x, fn v -> v * get_value(state, y) end) end
    end

    defp instruction_effect({"jnz", _args}) do
      fn state -> state end
    end

    defp instruction_jump({"jnz", [x, y]}) do
      fn state ->
        if get_value(state, x) != 0 do
          jump(state, get_value(state, y))
        else
          jump(state, 1)
        end
      end
    end

    defp instruction_jump({_op, _args}) do
      fn state -> jump(state, 1) end
    end

    defp jump(%__MODULE__{} = state, n) do
      case jump_instructions(state.instructions, n) do
        {:ok, instructions} -> Map.put(state, :instructions, instructions)
        {:error, reason} -> Map.put(state, :exit, reason)
      end
    end

    defp jump_instructions(instructions, 0) do
      {:ok, instructions}
    end

    defp jump_instructions(%{cursor: cursor, prev: prev, next: [next | rest]}, n) when n > 0 do
      jump_instructions(%{cursor: next, prev: [cursor | prev], next: rest}, n - 1)
    end

    defp jump_instructions(%{cursor: cursor, prev: [prev | rest], next: next}, n) when n < 0 do
      jump_instructions(%{cursor: prev, prev: rest, next: [cursor | next]}, n + 1)
    end

    defp jump_instructions(_, _) do
      {:error, :reach_the_end}
    end

    defp get_value(_state, x) when is_integer(x), do: x
    defp get_value(state, x), do: get_register(state, x)

    defp parse_instructions(raw_instructions) do
      [first | rest] = Enum.map(raw_instructions, &parse_instruction/1)
      %{cursor: first, prev: [], next: rest}
    end

    defp parse_instruction(<<op::binary-size(3), rest::binary>>) do
      {op, parse_args(rest)}
    end

    defp parse_args(str) do
      str
      |> String.splitter(" ", trim: true)
      |> Enum.map(fn x ->
        case Integer.parse(x) do
          :error -> x
          {n, _} -> n
        end
      end)
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day23Test do
      use ExUnit.Case

      test "part1" do
      end

      test "part2" do
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day23.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day23.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
