defmodule Day1 do
  def part1(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&String.to_integer/1)
    |> Stream.map(&calc_fuel/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&String.to_integer/1)
    |> Stream.map(&total_fuel/1)
    |> Enum.sum()
  end

  def calc_fuel(mass) do
    mass
    |> div(3)
    |> Kernel.-(2)
    |> max(0)
  end

  def total_fuel(mass) do
    total_fuel(mass, 0)
  end

  defp total_fuel(0, total) do
    total
  end

  defp total_fuel(mass_or_fuel, total) do
    fuel = calc_fuel(mass_or_fuel)
    total_fuel(fuel, total + fuel)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day1Test do
      use ExUnit.Case

      @input """
      12
      14
      1969
      100756
      """
      test "part1 result" do
        assert Day1.part1(@input) == 2 + 2 + 654 + 33583
      end

      @input """
      14
      1969
      100756
      """
      test "part2 result" do
        assert Day1.part2(@input) == 2 + 966 + 50346
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
