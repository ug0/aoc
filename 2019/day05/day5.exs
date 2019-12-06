defmodule Day5 do
  alias __MODULE__.Program

    input
    |> parse_input()
    |> Program.new(1)
    |> Program.execute()
    |> Program.diagnostic_code()
  end

  def part2(input) do
    input
    |> parse_input()
    |> Program.new(5)
    |> Program.execute()
    |> Program.diagnostic_code()
  end

  defp parse_input(input) do
    input
    |> String.splitter(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defmodule Program do
    defstruct [:memory, :pointer, :output, :input]

    def new(codes, input) do
      memory =
        codes
        |> Stream.with_index()
        |> Enum.into(%{}, fn {code, i} -> {i, code} end)

      %__MODULE__{
        memory: memory,
        input: input,
        pointer: 0,
        output: []
      }
    end

    def diagnostic_code(%__MODULE__{output: [code | _]}) do
      code
    end

    def read(%__MODULE__{memory: mem}, addr) do
      Map.get(mem, addr)
    end

    def write(%__MODULE__{memory: mem} = program, addr, value) do
      %{program | memory: Map.put(mem, addr, value)}
    end

    def execute(program) do
      case get_instruction(program) do
        :halt -> program
        {:ok, fun} -> program |> fun.() |> execute()
      end
    end

    defp get_instruction(%__MODULE__{pointer: addr} = program) do
      [opcode | params] = addr..(addr + 3) |> Enum.map(&read(program, &1))

      opcode
      |> to_string()
      |> String.pad_leading(5, "0")
      |> parse_instruction(params)
    end

    defp parse_instruction(<<_, _, _, "99">>, _) do
      :halt
    end

    defp parse_instruction(<<"0", m2, m1, "01">>, [param1, param2, param3]) do
      {:ok,
       fn program ->
         program
         |> write(param3, parse_param(program, {m1, param1}) + parse_param(program, {m2, param2}))
         |> increase_pointer(4)
       end}
    end

    defp parse_instruction(<<"0", m2, m1, "02">>, [param1, param2, param3]) do
      {:ok,
       fn program ->
         program
         |> write(param3, parse_param(program, {m1, param1}) * parse_param(program, {m2, param2}))
         |> increase_pointer(4)
       end}
    end

    defp parse_instruction(<<_, _, "0", "03">>, [param | _]) do
      {:ok, fn program -> program |> write(param, program.input) |> increase_pointer(2) end}
    end

    defp parse_instruction(<<_, _, m1, "04">>, [param | _]) do
      {:ok,
       fn program ->
         program
         |> output(parse_param(program, {m1, param}))
         |> increase_pointer(2)
       end}
    end

    defp parse_instruction(<<_, m2, m1, "05">>, [param1, param2 | _]) do
      {:ok,
       fn program ->
         case parse_param(program, {m1, param1}) do
           0 -> increase_pointer(program, 3)
           _ -> jump(program, parse_param(program, {m2, param2}))
         end
       end}
    end

    defp parse_instruction(<<_, m2, m1, "06">>, [param1, param2 | _]) do
      {:ok,
       fn program ->
         case parse_param(program, {m1, param1}) do
           0 -> jump(program, parse_param(program, {m2, param2}))
           _ -> increase_pointer(program, 3)
         end
       end}
    end

    defp parse_instruction(<<_, m2, m1, "07">>, [param1, param2, param3]) do
      {:ok,
       fn program ->
         v1 = parse_param(program, {m1, param1})
         v2 = parse_param(program, {m2, param2})

         case v1 < v2 do
           true -> write(program, param3, 1)
           false -> write(program, param3, 0)
         end
         |> increase_pointer(4)
       end}
    end

    defp parse_instruction(<<_, m2, m1, "08">>, [param1, param2, param3]) do
      {:ok,
       fn program ->
         v1 = parse_param(program, {m1, param1})
         v2 = parse_param(program, {m2, param2})

         case v1 == v2 do
           true -> write(program, param3, 1)
           false -> write(program, param3, 0)
         end
         |> increase_pointer(4)
       end}
    end

    defp jump(%__MODULE__{} = program, addr) do
      %{program | pointer: addr}
    end

    defp increase_pointer(%__MODULE__{pointer: addr} = program, inc) do
      %{program | pointer: addr + inc}
    end

    defp output(%__MODULE__{output: values} = program, v) do
      %{program | output: [v | values]}
    end

    defp parse_param(program, {?0, addr}) do
      read(program, addr)
    end

    defp parse_param(_program, {?1, value}) do
      value
    end
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
