defmodule Day13 do
  alias __MODULE__.Firewall

  def part1(input) do
    input
    |> parse_firewall()
    |> get_caught_severity()
  end

  def part2(input) do
    input
    |> parse_firewall()
    |> find_fewest_waiting_time_to_get_away()
  end

  defp get_caught_severity(firewall) do
    firewall
    |> Firewall.layer_states_when_packet_arrives()
    |> Stream.map(fn
      {depth, {range, 0, _inc}} -> depth * range
      _ -> 0
    end)
    |> Enum.sum()
  end

  # takes even longer than the first iteration
  defp find_fewest_waiting_time_to_get_away(firewall, delay \\ 0) do
    if will_get_caught?(firewall, delay) do
      firewall
      |> find_fewest_waiting_time_to_get_away(delay + 1)
    else
      delay
    end
  end

  defp will_get_caught?(firewall, delay) do
    firewall
    |> Firewall.layer_states_when_packet_arrives(delay)
    |> Enum.any?(fn {_depth, {_range, pos, _inc}} -> pos == 0 end)
  end

  defp parse_firewall(input) do
    Firewall.init(input)
  end

  defmodule Firewall do
    def init(input) do
      input
      |> String.splitter("\n", trim: true)
      |> Stream.map(&parse_layer/1)
      |> Enum.into(%{})
    end

    def layer_states_when_packet_arrives(firewall, delay \\ 0) do
      firewall
      |> Stream.map(fn {depth, scanner} ->
        {depth, scanner_move(scanner, depth + delay)}
      end)
    end

    defp scanner_move(scanner, 0) do
      scanner
    end

    defp scanner_move({range, pos, inc}, steps) when steps > 0 do
      case pos + inc do
        0 -> {range, 0, 1}
        bottom when bottom == range - 1 -> {range, bottom, -1}
        new_pos -> {range, new_pos, inc}
      end
      |> scanner_move(steps - 1)
    end

    defp parse_layer(layer) do
      [depth, range] =
        layer
        |> String.splitter(": ")
        |> Enum.map(&String.to_integer/1)

      {depth, {range, 0, 1}}
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day13Test do
      use ExUnit.Case

      @input """
      0: 3
      1: 2
      4: 4
      6: 4
      """
      test "part1 result" do
        assert Day13.part1(@input) == 24
      end

      test "part2 result" do
        assert Day13.part2(@input) == 10
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day13.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day13.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
