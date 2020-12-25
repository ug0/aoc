defmodule Aoc.Y2020.D25 do
  use Aoc.Input

  def part1 do
    [pub_key1, pub_key2] = parsed_input()

    pub_key1
    |> find_encryption_key(pub_key2)
    |> IO.inspect()
  end

  @subject_number 7
  def find_encryption_key(pub_key1, pub_key2) do
    1
    |> Stream.iterate(&(&1 + 1))
    |> Enum.find(&(gen_pub_key(&1, @subject_number) == pub_key1))
    |> gen_pub_key(pub_key2)
  end

  @divisor 20_201_227
  def gen_pub_key(loop_size, subject_number) do
    subject_number
    |> mod_pow(loop_size, @divisor)
    |> rem(@divisor)
  end

  defp mod_pow(n, p, m), do: mod_pow(n, p, m, 1)

  defp mod_pow(_n, 0, _m, acc) do
    acc
  end

  defp mod_pow(n, p, m, acc) when rem(p, 2) == 0 do
    mod_pow(rem(n * n, m), div(p, 2), m, acc)
  end

  defp mod_pow(n, p, m, acc) do
    mod_pow(n, p - 1, m, rem(n * acc, m))
  end

  defp parsed_input do
    input()
    |> String.splitter("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
