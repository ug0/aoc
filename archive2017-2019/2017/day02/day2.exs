defmodule Day2 do
  def part1(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&distance_of_row/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&div_of_row/1)
    |> Enum.sum()
  end

  defp distance_of_row(row) do
    {min, max} =
      row
      |> String.split()
      |> Stream.map(&String.to_integer/1)
      |> Enum.min_max()

    max - min
  end

  defp div_of_row(row) do
    nums =
      row
      |> String.split()
      |> Stream.map(&String.to_integer/1)

    [div] = for(i <- nums, j <- nums, i > j and rem(i, j) == 0, do: div(i, j))
    div
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day2Test do
      use ExUnit.Case

      @input """
      5 1 9 5
      7 5 3
      2 4 6 8
      """
      test "part1 result" do
        assert Day2.part1(@input) == 18
      end

      @input """
      5 9 2 8
      9 4 7 3
      3 8 6 5
      """
      test "part2 result" do
        assert Day2.part2(@input) == 9
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day2.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day2.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
