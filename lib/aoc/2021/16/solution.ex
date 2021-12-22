defmodule Aoc.Y2021.D16 do
  use Aoc.Input

  def part1(str \\ nil) do
    (str || input())
    |> to_binary_sequence()
    |> decode_packet()
    |> elem(0)
    |> versions_sum()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> to_binary_sequence()
    |> decode_packet()
    |> elem(0)
    |> eval()
    |> IO.inspect()
  end

  defp versions_sum(packet) do
    versions_sum(packet, 0)
  end

  defp versions_sum({{version, _}, subpackets}, sum) when is_list(subpackets) do
    subpackets
    |> Stream.map(&versions_sum/1)
    |> Enum.sum()
    |> Kernel.+(sum + String.to_integer(version, 2))
  end

  defp versions_sum({{version, _}, "" <> _}, sum) do
    String.to_integer(version, 2) + sum
  end

  @sum "000"
  @product "001"
  @minimum "010"
  @maximum "011"
  @literal "100"
  @greater "101"
  @less "110"
  @equal "111"
  defp eval({{_, @literal}, value}) do
    String.to_integer(value, 2)
  end

  defp eval({{_, operator_type}, subpackets}) do
    subpackets
    |> Stream.map(&eval/1)
    |> op(operator_type).()
  end

  defp op(operator_type) do
    case operator_type do
      @sum ->
        fn values -> Enum.sum(values) end

      @product ->
        fn values -> Enum.product(values) end

      @minimum ->
        fn values -> Enum.min(values) end

      @maximum ->
        fn values -> Enum.max(values) end

      @greater ->
        fn values ->
          case Enum.take(values, 2) do
            [x, y] when x > y -> 1
            _ -> 0
          end
        end

      @less ->
        fn values ->
          case Enum.take(values, 2) do
            [x, y] when x < y -> 1
            _ -> 0
          end
        end

      @equal ->
        fn values ->
          case Enum.take(values, 2) do
            [x, x] -> 1
            _ -> 0
          end
        end
    end
  end

  defp decode_packet(sequence) do
    sequence
    |> decode_packet_header()
    |> decode_packet_body()
  end

  defp decode_packet_header(<<version::binary-size(3), type::binary-size(3), rest::binary>>) do
    {{version, type}, rest}
  end

  defp decode_packet_body({{_, @literal} = header, sequence}) do
    {value, rest} = sequence |> decode_literal_value()
    {{header, value}, rest}
  end

  defp decode_packet_body({header, sequence}) do
    {packets, rest} = decode_subpackets(sequence)
    {{header, packets}, rest}
  end

  defp decode_literal_value(sequence, acc \\ "")

  defp decode_literal_value("1" <> <<value::binary-size(4), rest::binary>>, acc) do
    decode_literal_value(rest, acc <> value)
  end

  defp decode_literal_value("0" <> <<value::binary-size(4), rest::binary>>, acc) do
    {acc <> value, rest}
  end

  defp decode_subpackets("0" <> <<len::binary-size(15), rest::binary>>) do
    decode_subpackets(rest, {:bits, String.to_integer(len, 2)}, [])
  end

  defp decode_subpackets("1" <> <<len::binary-size(11), rest::binary>>) do
    decode_subpackets(rest, {:packets, String.to_integer(len, 2)}, [])
  end

  defp decode_subpackets(rest, {_, 0}, packets) do
    {Enum.reverse(packets), rest}
  end

  defp decode_subpackets(sequence, remaining, packets) do
    {packet, rest} = decode_packet(sequence)

    decode_subpackets(
      rest,
      reduce_remaining(remaining, String.length(sequence) - String.length(rest)),
      [packet | packets]
    )
  end

  defp reduce_remaining({:bits, len}, n), do: {:bits, len - n}
  defp reduce_remaining({:packets, n}, _), do: {:packets, n - 1}

  defp to_binary_sequence(str) do
    str
    |> String.trim_trailing()
    |> String.graphemes()
    |> Stream.map(fn n ->
      n |> String.to_integer(16) |> Integer.to_string(2) |> String.pad_leading(4, "0")
    end)
    |> Enum.join()
  end
end
