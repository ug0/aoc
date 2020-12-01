Code.load_file("../intcode_program.exs", __DIR__)

defmodule Day7 do
  alias IntcodeProgram, as: Program

  def part1(program) do
    signal_probe = spawn_link(__MODULE__, :capture_highest_signal, [0, self()])

    [0, 1, 2, 3, 4]
    |> all_sequences()
    |> Stream.map(&build_amp_series(&1, program, signal_probe))
    |> Enum.each(&try_amp_series/1)

    receive do
      {:highest_signal, value} -> value
    after
      3000 -> :timeout
    end
  end

  def part2(program) do
    signal_probe = spawn_link(__MODULE__, :capture_highest_signal, [0, self()])

    [5, 6, 7, 8, 9]
    |> all_sequences()
    |> Stream.map(&build_amp_series(&1, program, nil))
    |> Stream.map(&connect_last_and_first_amps(&1, signal_probe))
    |> Enum.each(&try_amp_series/1)

    receive do
      {:highest_signal, signal} -> signal
    after
      3000 -> :timeout
    end
  end

  defp connect_last_and_first_amps([first_amp | rest_amps] = amps, signal_probe) do
    last_amp = Enum.at(rest_amps, -1)

    send(
      last_amp.output,
      {:set_hook, spawn_link(__MODULE__, :signal_broadcast, [[first_amp.input, signal_probe]])}
    )

    amps
  end

  defp try_amp_series(amps) do
    amps
    |> Enum.each(fn amp ->
      Task.start(fn -> Program.execute(amp) end)
    end)
  end

  def capture_highest_signal(signal, feedback) do
    receive do
      {:signal, value} -> value |> max(signal) |> capture_highest_signal(feedback)
    after
      300 -> send(feedback, {:highest_signal, signal})
    end
  end

  def signal_broadcast(hooks) do
    receive do
      term ->
        Enum.each(hooks, &send(&1, term))
    end

    signal_broadcast(hooks)
  end

  defp build_amp_series(settings, codes, first_hook) do
    build_amp_series(settings, codes, first_hook, [])
  end

  defp build_amp_series([], _codes, hook, amps) do
    send(hook, {:signal, 0})
    amps
  end

  defp build_amp_series([setting | rest], codes, hook, amps) do
    input = gen_input([setting])
    amp = Program.new(codes, input, gen_output(hook))
    build_amp_series(rest, codes, input, [amp | amps])
  end

  defp all_sequences([]) do
    [[]]
  end

  defp all_sequences(list) do
    Enum.flat_map(list, fn e ->
      List.delete(list, e)
      |> all_sequences()
      |> Enum.map(&[e | &1])
    end)
  end

  defp gen_input(values) do
    spawn_link(__MODULE__, :input_fun, [values])
  end

  defp gen_output(hook) do
    spawn_link(__MODULE__, :output_fun, [hook])
  end

  def input_fun([input | rest] = inputs) do
    receive do
      {:read_input, pid} ->
        send(pid, input)
        input_fun(rest)

      {:signal, value} ->
        input_fun(inputs ++ [value])
    end
  end

  def input_fun([]) do
    receive do
      {:signal, value} ->
        input_fun([value])
    after
      500 -> nil
    end
  end

  def output_fun(hook) do
    receive do
      {:write_output, value} ->
        send(hook, {:signal, value})

      {:set_hook, pid} ->
        output_fun(pid)
    end

    output_fun(hook)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day7Test do
      use ExUnit.Case

      test "part1" do
        assert Day7.part1("3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0") == 43210

        assert Day7.part1(
                 "3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0"
               ) == 54321

        assert Day7.part1(
                 "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"
               ) == 65210
      end

      test "part2" do
        assert Day7.part2(
                 "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5"
               ) == 139_629_729

        assert Day7.part2(
                 "3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10"
               ) == 18216
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day7.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day7.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
