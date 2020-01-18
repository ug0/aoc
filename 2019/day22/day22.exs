defmodule Day22 do
  def part1(techniques) do
    deck_size = 10007

    techniques
    |> String.split("\n", trim: true)
    |> shuffle(deck_size)
    |> calc_pos(deck_size, 2019)
  end

  def part2(techniques) do
    deck_size = 119_315_717_514_047
    rounds = 101_741_582_076_661

    techniques
    |> String.split("\n", trim: true)
    |> shuffle(deck_size)
    |> repeat(deck_size, rounds)
    |> inverse(deck_size)
    |> calc_pos(deck_size, 2020)
  end

  defp repeat({a, b}, deck_size, rounds) do
    repeat({1, 0}, {a, b}, deck_size, rounds)
  end

  defp repeat(acc, _factors, _deck_size, _rounds = 0) do
    acc
  end

  defp repeat(acc, factors, deck_size, rounds) when rem(rounds, 2) == 0 do
    repeat(acc, compose(factors, factors, deck_size), deck_size, div(rounds, 2))
  end

  defp repeat(acc, factors, deck_size, rounds) do
    acc
    |> compose(factors, deck_size)
    |> repeat(factors, deck_size, rounds - 1)
  end

  defp inverse({a, b}, deck_size) do
    # ax + b = y
    # x = (1/a)y - b/a

    {moddiv(1, a, deck_size), moddiv(-b, a, deck_size)}
  end

  defp shuffle(techniques, deck_size) do
    techniques
    |> Stream.map(&parse_tech(&1, deck_size))
    |> Enum.reduce({1, 0}, fn next, acc ->
      compose(acc, next, deck_size)
    end)
  end

  defp calc_pos({a, b}, deck_size, pos) do
    mod(a * pos + b, deck_size)
  end

  defp compose({a1, b1}, {a2, b2}, deck_size) do
    {mod(a1 * a2, deck_size), mod(a2 * b1 + b2, deck_size)}
  end

  defp parse_tech("deal into new stack", size) do
    {-1, size - 1}
  end

  defp parse_tech("cut " <> n, _size) do
    {1, -String.to_integer(n)}
  end

  defp parse_tech("deal with increment " <> n, _size) do
    {String.to_integer(n), 0}
  end

  def mod(n, m) do
    case rem(n, m) do
      x when x < 0 -> x + m
      x -> x
    end
  end

  # assumption: m is a prime
  def moddiv(a, b, m) do
    mod(a * modpow(b, m - 2, m), m)
  end

  def modpow(base, exp, m) do
    modpow(1, base, exp, m)
  end

  defp modpow(acc, _base, 0, _m) do
    acc
  end

  defp modpow(acc, base, exp, m) when rem(exp, 2) == 0 do
    modpow(acc, mod(base * base, m), div(exp, 2), m)
  end

  defp modpow(acc, base, exp, m) do
    (acc * base)
    |> mod(m)
    |> modpow(base, exp - 1, m)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day22Test do
      use ExUnit.Case
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day22.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day22.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
