defmodule Day16 do
  def part1(str) do
    str
    |> to_charlist()
    |> Stream.map(fn digit -> digit - ?0 end)
    |> Stream.iterate(fn digits ->
      digits
      |> Stream.with_index(1)
      |> Task.async_stream(fn {_, i} -> calc_digit(digits, i) end)
      |> Enum.map(fn {:ok, digit} -> digit end)
    end)
    |> Enum.at(100)
    |> Stream.take(8)
    |> Enum.join()
  end

  defp calc_digit(digits, offset) do
    digits
    |> Stream.zip(pattern(offset))
    |> Stream.map(fn {a, b} -> a * b end)
    |> Stream.drop(offset - 1)
    |> Enum.sum()
    |> digit_from_sum()
  end

  @base_pattern [0, 1, 0, -1]
  defp pattern(offset) do
    @base_pattern
    |> Stream.flat_map(fn n ->
      List.duplicate(n, offset)
    end)
    |> Stream.cycle()
    |> Stream.drop(1)
  end

  def part2(str) do
    digits =
      str
      |> String.duplicate(10000)
      |> to_charlist()
      |> Stream.map(fn digit -> digit - ?0 end)

    offset =
      digits
      |> Enum.take(7)
      |> Integer.undigits()

    digits
    |> Enum.drop(offset)
    |> Stream.iterate(fn digits ->
      digits
      |> Enum.reverse()
      |> next_phase(0, [])
    end)
    |> Enum.at(100)
    |> Stream.take(8)
    |> Enum.join()
  end

  defp next_phase(_reversed_digits = [], _sum, result) do
    result
  end

  defp next_phase([next | rest], sum, result) do
    new_sum = next + sum
    next_phase(rest, new_sum, [digit_from_sum(new_sum) | result])
  end

  defp digit_from_sum(sum) do
    sum
    |> rem(10)
    |> abs()
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day16Test do
      use ExUnit.Case

      test "part1" do
        assert Day16.part1("80871224585914546619083218645595") == "24176176"
        assert Day16.part1("19617804207202209144916044189917") == "73745418"
        assert Day16.part1("69317163492948606335995924319873") == "52432133"
      end

      test "part2" do
        assert Day16.part2("03036732577212944063491565474664") == "84462026"
        assert Day16.part2("02935109699940807407585447034323") == "78725270"
        assert Day16.part2("03081770884921959731165446850517") == "53553731"
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day16.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day16.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
