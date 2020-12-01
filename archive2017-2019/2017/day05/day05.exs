defmodule Day5 do
  def part1(input) do
    input
    |> parse_instructions()
    |> execute_instructions()
    |> elem(1)
    |> length()
  end

  defp parse_instructions(input) do
    instructions = :ets.new(:instructions, [:set])

    input
    |> String.split("\n", trim: true)
    |> Stream.with_index()
    |> Enum.each(fn {n, i} ->
      :ets.insert(instructions, {i, String.to_integer(n)})
    end)

    instructions
  end

  defp execute_instructions(instructions, update_fun \\ &(&1 + 1)) do
    execute_instructions(instructions, 0, [], update_fun)
  end

  defp execute_instructions(instructions, pos, executed, update_fun) do
    case get_i(instructions, pos) do
      nil ->
        {:exit, executed, instructions}

      num ->
        execute_instructions(
          put_i(instructions, pos, update_fun.(num)),
          pos + num,
          [{pos, num} | executed],
          update_fun
        )
    end
  end

  defp get_i(instructions, pos) do
    case :ets.lookup(instructions, pos) do
      [{_, value}] -> value
      [] -> nil
    end
  end

  defp put_i(instructions, pos, value) do
    true = :ets.insert(instructions, {pos, value})
    instructions
  end

  def part2(input) do
    input
    |> parse_instructions()
    |> execute_instructions(fn
      n when n >= 3 -> n - 1
      n -> n + 1
    end)
    |> elem(1)
    |> length()
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day5Test do
      use ExUnit.Case

      @input """
      0
      3
      0
      1
      -3
      """
      test "part1 result" do
        assert Day5.part1(@input) == 5
      end

      test "part2 result" do
        assert Day5.part2(@input) == 10
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day5.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day5.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
