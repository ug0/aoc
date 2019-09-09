defmodule Day13 do
  alias __MODULE__.Firewall

  def part1(input) do
    {_firewall, severity} =
      input
      |> parse_firewall()
      |> go_through_each_layer(0, fn
        severity, :safe -> {:cont, severity}
        severity, {:caught, inc} -> {:cont, severity + inc}
      end)

    severity
  end

  def part2(input) do
    input
    |> parse_firewall()
    |> find_fewest_waiting_time_to_get_away()
  end

  # takes some time to execute
  defp find_fewest_waiting_time_to_get_away(firewall, delay \\ 0) do
    if will_get_caught?(firewall) do
      firewall
      |> wait(1)
      |> find_fewest_waiting_time_to_get_away(delay + 1)
    else
      delay
    end
  end

  defp will_get_caught?(firewall) do
    {_firewall, caught?} =
      firewall
      |> go_through_each_layer(false, fn
        _, :safe -> {:cont, false}
        _, {:caught, _} -> {:halt, true}
      end)

    caught?
  end

  defp parse_firewall(input) do
    Firewall.init(input)
  end

  defp wait(firewall, 0) do
    firewall
  end

  defp wait(firewall, picoseconds) do
    firewall
    |> Firewall.next()
    |> wait(picoseconds - 1)
  end

  defp go_through_each_layer(firewall, state, fun) do
    0..Firewall.max_depth(firewall)
    |> Enum.reduce_while({firewall, state}, fn depth, {firewall, state} ->
      case fun.(state, Firewall.reach_layer(firewall, depth)) do
        {:cont, new_state} -> {:cont, {Firewall.next(firewall), new_state}}
        {:halt, result} -> {:halt, {firewall, result}}
      end
    end)
  end


  defmodule Firewall do
    def init(input) do
      input
      |> String.splitter("\n", trim: true)
      |> Stream.map(&parse_layer/1)
      |> Enum.into(%{})
    end

    def max_depth(firewall) do
      firewall
      |> Map.keys()
      |> Enum.max()
    end

    def reach_layer(firewall, depth) do
      case Map.get(firewall, depth) do
        {range, 0, _inc} -> {:caught, range * depth}
        _ -> :safe
      end
    end

    def next(firewall) do
      firewall
      |> Stream.map(&layer_next_state/1)
      |> Enum.into(%{})
    end

    defp layer_next_state({depth, {range, pos, inc}}) do
      case pos + inc do
        0 -> {depth, {range, 0, 1}}
        bottom when bottom == range - 1 -> {depth, {range, bottom, -1}}
        new_pos -> {depth, {range, new_pos, inc}}
      end
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
