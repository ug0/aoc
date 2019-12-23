defmodule Day22 do
  def part1(techniques) do
    deck_size = 10007

    pos_calculator(
      String.split(techniques, "\n", trim: true),
      deck_size
    ).(2019)
  end

  def part2(_techniques) do
  end

  defp pos_calculator(techniques, deck_size) do
    fn pos ->
      techniques
      |> Enum.reduce(pos, fn tech, new_pos ->
        calc_new_pos(new_pos, deck_size, tech)
      end)
    end
  end

  defp calc_new_pos(pos, size, "deal into new stack") do
    size - 1 - pos
  end

  defp calc_new_pos(pos, size, "cut " <> n) do
    fit_in_range(pos - String.to_integer(n), size)
  end

  defp calc_new_pos(pos, size, "deal with increment " <> n) do
    fit_in_range(pos * String.to_integer(n), size)
  end

  defp fit_in_range(n, size) do
    case rem(n, size) do
      x when x < 0 -> x + size
      x -> x
    end
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
