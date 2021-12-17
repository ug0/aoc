defmodule Aoc.Y2021.D14 do
  use Aoc.Input

  def part1(str \\ nil) do
    {letter_freqs, pair_freqs, rules} =
      (str || input())
      |> parse_input()


    {{_, min}, {_, max}} =
      {letter_freqs, pair_freqs}
      |> Stream.iterate(&iterate(&1, rules))
      |> Enum.at(10)
      |> elem(0)
      |> Enum.min_max_by(fn {_, c} -> c end)

    (max - min)
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    {letter_freqs, pair_freqs, rules} =
      (str || input())
      |> parse_input()


    {{_, min}, {_, max}} =
      {letter_freqs, pair_freqs}
      |> Stream.iterate(&iterate(&1, rules))
      |> Enum.at(40)
      |> elem(0)
      |> Enum.min_max_by(fn {_, c} -> c end)

    (max - min)
    |> IO.inspect()
  end

  defp iterate({letter_freqs, pair_freqs}, rules) do
    Enum.reduce(pair_freqs, {letter_freqs, %{}}, fn {[left, right] = pair, count},
                                                    {new_letter_freqs, new_pair_freqs} ->
      case Map.get(rules, pair) do
        nil ->
          {new_letter_freqs, new_pair_freqs}

        i ->
          {update_freq(new_letter_freqs, i, count),
           [[left, i], [i, right]] |> Enum.reduce(new_pair_freqs, &update_freq(&2, &1, count))}
      end
    end)
  end

  defp update_freq(freqs, key, n) do
    Map.update(freqs, key, n, &(&1 + n))
  end

  defp parse_input(str) do
    [template, rules] = String.split(str, "\n\n", trim: true)
    template = to_charlist(template)

    {
      Enum.frequencies(template),
      template |> Stream.chunk_every(2, 1, :discard) |> Enum.frequencies(),
      rules
      |> String.splitter("\n", trim: true)
      |> Enum.into(%{}, fn line ->
        [pair, <<insertion>>] = String.split(line, " -> ")
        {to_charlist(pair), insertion}
      end)
    }
  end
end
