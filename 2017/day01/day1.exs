defmodule Day1 do
  def part1(num_str) do
    num_str
    |> num_digits()
    |> calc_part1()
  end

  def part2(num_str) do
    num_str
    |> num_digits()
    |> calc_part2()
  end

  defp num_digits(num_str) do
    num_str
    |> String.codepoints()
    |> Enum.map(&String.to_integer/1)
  end

  defp calc_part1([h | _] = nums) do
    calc_part1(0, nums, [h])
  end

  defp calc_part1(sum, [], _) do
    sum
  end

  defp calc_part1(sum, [last], [first]) do
    calc_part1(sum, [last, first], [])
  end

  defp calc_part1(sum, [h | [h | _] = t], first) do
    calc_part1(sum + h, t, first)
  end

  defp calc_part1(sum, [_ | t], first) do
    calc_part1(sum, t, first)
  end

  defp calc_part2(nums) do
    nums
    |> Stream.with_index()
    |> Stream.filter(fn {n, i} ->
      n == Enum.at(nums, rem(i + div(length(nums), 2), length(nums)))
    end)
    |> Stream.map(fn {n, _} -> n end)
    |> Enum.sum()
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day1Test do
      use ExUnit.Case

      test "part1 result" do
        assert Day1.part1("1122") == 3
        assert Day1.part1("1111") == 4
        assert Day1.part1("1234") == 0
        assert Day1.part1("91212129") == 9
      end

      test "part2 result" do
        assert Day1.part2("1212") == 6
        assert Day1.part2("1221") == 0
        assert Day1.part2("123425") == 4
        assert Day1.part2("123123") == 12
        assert Day1.part2("12131415") == 4
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day1.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day1.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
