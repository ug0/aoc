defmodule Day4 do
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.count(fn phrase ->
      is_valid?(String.split(phrase), &(&1 != &2))
    end)
  end

  defp is_valid?([], _valid_fun), do: true
  defp is_valid?([h | t], valid_fun) do
    Enum.all?(t, &(valid_fun.(&1, h))) && is_valid?(t, valid_fun)
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.count(fn phrase ->
      is_valid?(String.split(phrase), &not_same_or_anagrams/2)
    end)
  end

  defp not_same_or_anagrams(a, b) do
    sorted_letters_a = a |> String.graphemes() |> Enum.sort()
    sorted_letters_b = b |> String.graphemes() |> Enum.sort()

    sorted_letters_a != sorted_letters_b
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day4Test do
      use ExUnit.Case

      @input """
      aa bb cc dd ee
      aa bb cc dd aa
      aa bb cc dd aaa
      """
      test "part1 result" do
        assert Day4.part1(@input) == 2
      end

      @input """
      abcde fghij
      abcde xyz ecdab
      a ab abc abd abf abj
      iiii oiii ooii oooi oooo
      oiii ioii iioi iiio
      """
      test "part2 result" do
        assert Day4.part2(@input) == 3
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day4.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day4.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
