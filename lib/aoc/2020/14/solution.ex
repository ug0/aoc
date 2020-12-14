defmodule Aoc.Y2020.D14 do
  use Aoc.Input

  defmodule Program do
    defstruct [:mask, :mem, :version]

    def new(version \\ 1) when version in [1, 2] do
      %__MODULE__{
        mask: nil,
        mem: %{},
        version: version
      }
    end

    def sum(%__MODULE__{mem: mem}) do
      mem
      |> Stream.map(fn
        {_, v} when is_integer(v) -> v
        {_, v} -> binary_to_integer(v)
      end)
      |> Enum.sum()
    end

    def execute(%__MODULE__{} = program, {:mask, mask}) do
      Map.put(program, :mask, mask)
    end

    def execute(%__MODULE__{mem: mem, mask: mask, version: 1} = program, {:mem, address, value}) do
      %{program | mem: Map.put(mem, address, mask_value(value, mask))}
    end

    def execute(%__MODULE__{mem: mem, mask: mask, version: 2} = program, {:mem, address, value}) do
      new_mem =
        address
        |> decode_address(mask)
        |> Enum.reduce(mem, &Map.put(&2, &1, value))

      %{program | mem: new_mem}
    end

    defp mask_value(value, mask) when is_integer(value) do
      value
      |> integer_to_binary()
      |> mask_value(mask, [])
    end

    defp mask_value([], [], result) do
      Enum.reverse(result)
    end

    defp mask_value([h1 | t1], [?X | t2], result) do
      mask_value(t1, t2, [h1 | result])
    end

    defp mask_value([_ | t1], [bit | t2], result) do
      mask_value(t1, t2, [bit | result])
    end

    defp decode_address(address, mask) when is_integer(address) do
      address
      |> integer_to_binary()
      |> decode_address(mask, [])
    end

    defp decode_address([], [], result) do
      result
      |> Enum.reverse()
      |> to_string()
      |> float_address()
    end

    defp decode_address([bit | t1], [?0 | t2], result) do
      decode_address(t1, t2, [bit | result])
    end

    defp decode_address([_ | t1], [?1 | t2], result) do
      decode_address(t1, t2, [?1 | result])
    end

    defp decode_address([_ | t1], [?X | t2], result) do
      decode_address(t1, t2, [?X | result])
    end

    defp float_address(address_str) do
      case String.split(address_str, "X", parts: 2) do
        [left, right] ->
          right
          |> float_address()
          |> Enum.flat_map(fn address ->
            [left <> "0" <> address, left <> "1" <> address]
          end)

        whole ->
          whole
      end
    end

    @size 36
    defp integer_to_binary(num) do
      num
      |> Integer.to_string(2)
      |> String.pad_leading(@size, "0")
      |> to_charlist()
    end

    defp binary_to_integer(list) when is_list(list) do
      list
      |> to_string()
      |> binary_to_integer()
    end

    defp binary_to_integer(bin) when is_binary(bin) do
      String.to_integer(bin, 2)
    end
  end

  alias Aoc.Y2020.D14.Program

  def part1(str \\ nil) do
    (str || input())
    |> parse_input()
    |> Enum.reduce(Program.new(1), &Program.execute(&2, &1))
    |> Program.sum()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> parse_input()
    |> Enum.reduce(Program.new(2), &Program.execute(&2, &1))
    |> Program.sum()
    |> IO.inspect()
  end

  defp parse_input(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Enum.map(fn
      "mask = " <> mask ->
        {:mask, to_charlist(mask)}

      "mem[" <> s ->
        [address, value] = String.split(s, "] = ")
        {:mem, String.to_integer(address), String.to_integer(value)}
    end)
  end
end
