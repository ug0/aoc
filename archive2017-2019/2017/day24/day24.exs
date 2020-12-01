defmodule Day24 do
  def part1(input) do
    input
    |> parse_components()
    |> find_all_valid_bridges()
    |> Stream.map(&Enum.sum/1)
    |> Enum.max()
  end

  def part2(input) do
    input
    |> parse_components()
    |> find_all_valid_bridges()
    |> Stream.map(&{length(&1), Enum.sum(&1)})
    |> Enum.sort()
    |> List.last()
    |> elem(1)
  end

  defp add_component([top | _] = bridge, [top, port]) do
    {:ok, [port, top | bridge]}
  end

  defp add_component([top | _] = bridge, [port, top]) do
    {:ok, [port, top | bridge]}
  end

  defp add_component(_, _) do
    :error
  end

  defp find_all_valid_bridges(components) do
    find_all_valid_bridges([{[0], components}], [])
  end

  defp find_all_valid_bridges([] = _in_progress, done) do
    done
  end

  defp find_all_valid_bridges([{bridge, _} = next | rest], done) do
    case options_for_adding_next_component(next) do
      [] -> find_all_valid_bridges(rest, [bridge | done])
      new_options -> find_all_valid_bridges(rest ++ new_options, done)
    end
  end

  defp options_for_adding_next_component({bridge, components}) do
    options_for_adding_next_component(bridge, [], [], components, [])
  end

  defp options_for_adding_next_component(_bridge, _valid, _invalid, [] = _unchecked, options) do
    options
  end

  defp options_for_adding_next_component(bridge, valid, invalid, [next | rest], options) do
    case add_component(bridge, next) do
      {:ok, new_bridge} -> options_for_adding_next_component(bridge, [next | valid], invalid, rest, [{new_bridge, valid ++ invalid ++ rest} | options])
      :error -> options_for_adding_next_component(bridge, valid, [next | invalid], rest, options)
    end
  end

  defp parse_components(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Enum.map(fn c ->
      c
      |> String.splitter("/")
      |> Enum.map(&String.to_integer/1)
    end)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day24Test do
      use ExUnit.Case

      @input """
      0/2
      2/2
      2/3
      3/4
      3/5
      0/1
      10/1
      9/10
      """
      test "part1" do
        assert Day24.part1(@input) == 31
      end

      test "part2" do
        assert Day24.part2(@input) == 19
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day24.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day24.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
