defmodule IntcodeProgram do
  defstruct [:memory, :pointer, :output, :input, :relative_base]

  def new(codes, input, output) do
    memory =
      codes
      |> Stream.with_index()
      |> Enum.into(%{}, fn {code, i} -> {i, code} end)

    %__MODULE__{
      memory: memory,
      input: input,
      pointer: 0,
      output: output,
      relative_base: 0
    }
  end

  def diagnostic_code(%__MODULE__{output: [code | _]}) do
    code
  end

  def read(%__MODULE__{memory: mem}, addr) do
    Map.get(mem, addr, 0)
  end

  def write(%__MODULE__{memory: mem} = program, addr, value) do
    %{program | memory: Map.put(mem, addr, value)}
  end

  def execute(%__MODULE__{} = program) do
    case get_instruction(program) do
      :halt ->
        program

      {:ok, fun} ->
        program |> fun.() |> execute()
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

  defp parse_instruction(<<m3, m2, m1, "01">>, [param1, param2, param3]) do
    {:ok,
     fn program ->
       program
       |> write(
         parse_addr(program, {m3, param3}),
         parse_param(program, {m1, param1}) + parse_param(program, {m2, param2})
       )
       |> increase_pointer(4)
     end}
  end

  defp parse_instruction(<<m3, m2, m1, "02">>, [param1, param2, param3]) do
    {:ok,
     fn program ->
       program
       |> write(
         parse_addr(program, {m3, param3}),
         parse_param(program, {m1, param1}) * parse_param(program, {m2, param2})
       )
       |> increase_pointer(4)
     end}
  end

  defp parse_instruction(<<_, _, mode, "03">>, [param | _]) do
    {:ok,
     fn program ->
       program
       |> write(parse_addr(program, {mode, param}), read_input(program))
       |> increase_pointer(2)
     end}
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

  defp parse_instruction(<<m3, m2, m1, "07">>, [param1, param2, param3]) do
    {:ok,
     fn program ->
       v1 = parse_param(program, {m1, param1})
       v2 = parse_param(program, {m2, param2})

       case v1 < v2 do
         true -> write(program, parse_addr(program, {m3, param3}), 1)
         false -> write(program, parse_addr(program, {m3, param3}), 0)
       end
       |> increase_pointer(4)
     end}
  end

  defp parse_instruction(<<m3, m2, m1, "08">>, [param1, param2, param3]) do
    {:ok,
     fn program ->
       v1 = parse_param(program, {m1, param1})
       v2 = parse_param(program, {m2, param2})

       case v1 == v2 do
         true -> write(program, parse_addr(program, {m3, param3}), 1)
         false -> write(program, parse_addr(program, {m3, param3}), 0)
       end
       |> increase_pointer(4)
     end}
  end

  defp parse_instruction(<<_, _, mode, "09">>, [param | _]) do
    {:ok,
     fn program ->
       program
       |> increase_relative_base(parse_param(program, {mode, param}))
       |> increase_pointer(2)
     end}
  end

  defp jump(%__MODULE__{} = program, addr) do
    %{program | pointer: addr}
  end

  defp increase_pointer(%__MODULE__{pointer: addr} = program, inc) do
    %{program | pointer: addr + inc}
  end

  defp increase_relative_base(%__MODULE__{relative_base: base} = program, inc) do
    %{program | relative_base: base + inc}
  end

  defp read_input(%__MODULE__{input: input}) do
    send(input, {:read_input, self()})

    receive do
      input -> input
    end
  end

  defp output(%__MODULE__{output: output} = program, v) do
    send(output, {:write_output, v})
    program
  end

  defp parse_param(_program, {?1, value}) do
    value
  end

  defp parse_param(program, param_with_mode) do
    read(program, parse_addr(program, param_with_mode))
  end

  defp parse_addr(_program, {?0, addr}) do
    addr
  end

  defp parse_addr(%__MODULE__{relative_base: base}, {?2, addr}) do
    base + addr
  end
end
