defmodule Day15 do
  use Bitwise, only_operators: true

  def part1(input) do
    input
    |> parse_input()
    |> pair_stream(generator(:part1))
    |> Stream.take(40_000_000)
    |> Enum.count(&match?/1)
  end

  def part2(input) do
    input
    |> parse_input()
    |> pair_stream(generator(:part2))
    |> Stream.take(5_000_000)
    |> Enum.count(&match?/1)
  end

  def pair_stream(start, generator) do
    start
    |> Stream.iterate(generator)
    |> Stream.drop(1)
  end

  def generator(:part1) do
    fn pair ->
      next_pair(pair, fn _ -> true end, fn _ -> true end)
    end
  end

  def generator(:part2) do
    fn pair ->
      next_pair(pair, &(rem(&1, 4) == 0), &(rem(&1, 8) == 0))
    end
  end

  @factors {16807, 48271}
  defp next_pair({a, b}, fun_a, fun_b) do
    {factor_a, factor_b} = @factors
    {produce_next(a, factor_a, fun_a), produce_next(b, factor_b, fun_b)}
  end

  defp produce_next(prev, factor, valid_fun) do
    next = rem(prev * factor, 2_147_483_647)

    if valid_fun.(next) do
      next
    else
      produce_next(next, factor, valid_fun)
    end
  end

  defp match?({a, b}) do
    (a &&& 65535) == (b &&& 65535)
  end

  defp parse_input(input) do
    [
      "Generator A starts with " <> a,
      "Generator B starts with " <> b
    ] = String.split(input, "\n", trim: true)

    {String.to_integer(a), String.to_integer(b)}
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day15Test do
      use ExUnit.Case

      @input """
      Generator A starts with 65
      Generator B starts with 8921
      """
      test "part1 result" do
        assert Day15.part1(@input) == 588
      end

      test "part2 result" do
        assert Day15.part2(@input) == 309
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day15.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day15.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
