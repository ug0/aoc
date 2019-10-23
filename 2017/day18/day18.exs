defmodule Day18 do
  alias __MODULE__.Program

  def part1(input) do
    {p0, _} = spawn_monitor(&Program.init/0)

    program =
      Program.new(
        0,
        String.split(input, "\n", trim: true),
        fn state, v ->
          Map.update!(state, :sent, &[v | &1])
        end,
        fn state, key ->
          if Program.get_register(state, key) != 0 do
            Map.put(state, :exit, :rcv)
          else
            state
          end
        end
      )

    send(p0, {:start, self(), program})

    receive do
      {:exit, :rcv, %{sent: [v | _]}} -> v
    end
  end

  def part2(input) do
    {p0, _} = spawn_monitor(&Program.init/0)
    {p1, _} = spawn_monitor(&Program.init/0)

    instructions = String.split(input, "\n", trim: true)

    program0 = Program.new(0, instructions, sender(p1), receiver())
    program1 = Program.new(1, instructions, sender(p0), receiver())

    send(p0, {:start, self(), program0})
    send(p1, {:start, self(), program1})

    receive do
      {:exit, _, %{id: 1, sent: sent}} -> length(sent)
    end

  end

  defp sender(pid) do
    fn state, v ->
      send(pid, {:sound, v})
      Map.update!(state, :sent, &[v | &1])
    end
  end

  defp receiver do
    fn state, key ->
      receive do
        {:sound, v} -> Program.update_register(state, key, fn _ -> v end)
      after
        1000 -> Map.put(state, :exit, :timeout)
      end
    end
  end

  defmodule Program do
    defstruct id: nil,
              registers: %{},
              instructions: nil,
              sent: [],
              exit: nil,
              sender: nil,
              receiver: nil

    def init do
      receive do
        {:start, pid, state} -> run(state) |> return(pid)
      end
    end

    def new(id, instructions, sender, receiver) do
      %__MODULE__{
        id: id,
        instructions: parse_instructions(instructions),
        sender: sender,
        receiver: receiver
      }
      |> update_register("p", fn _ -> id end)
    end

    def run(%__MODULE__{exit: nil} = state) do
      state
      |> execute_instruction()
      |> run()
    end

    def run(%__MODULE__{} = state) do
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

    defp instruction_effect({"snd", [x]}) do
      fn state -> send_value(state, get_value(state, x)) end
    end

    defp instruction_effect({"set", [x, y]}) do
      fn state -> update_register(state, x, fn _ -> get_value(state, y) end) end
    end

    defp instruction_effect({"add", [x, y]}) do
      fn state -> update_register(state, x, fn v -> v + get_value(state, y) end) end
    end

    defp instruction_effect({"mul", [x, y]}) do
      fn state -> update_register(state, x, fn v -> v * get_value(state, y) end) end
    end

    defp instruction_effect({"mod", [x, y]}) do
      fn state -> update_register(state, x, fn v -> rem(v, get_value(state, y)) end) end
    end

    defp instruction_effect({"rcv", [x]}) do
      fn state -> expect_sound(state, x) end
    end

    defp instruction_effect({"jgz", _args}) do
      fn state -> state end
    end

    defp instruction_jump({"jgz", [x, y]}) do
      fn state ->
        if get_value(state, x) > 0 do
          jump(state, get_value(state, y))
        else
          jump(state, 1)
        end
      end
    end

    defp instruction_jump({_op, _args}) do
      fn state -> jump(state, 1) end
    end

    defp send_value(%__MODULE__{sender: fun} = state, v) do
      fun.(state, v)
    end

    defp expect_sound(%__MODULE__{receiver: fun} = state, k) do
      fun.(state, k)
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

    defmodule Day18Test do
      use ExUnit.Case

      @input """
      set a 1
      add a 2
      mul a a
      mod a 5
      snd a
      set a 0
      rcv a
      jgz a -1
      set a 1
      jgz a -2
      """
      test "part1 result" do
        assert Day18.part1(@input) == 4
      end

      @input """
      snd 1
      snd 2
      snd p
      rcv a
      rcv b
      rcv c
      rcv d
      """
      test "part2 result" do
        assert Day18.part2(@input) == 3
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day18.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day18.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
