defmodule Day8 do
  def part1(input, wide \\ 25, tall \\ 6) do
    input
    |> to_charlist()
    |> parse_layers(wide, tall)
    |> Enum.min_by(&Enum.count(&1, fn digit -> digit == ?0 end))
    |> Enum.reduce([0, 0], fn
      ?1, [one_count, two_count] -> [one_count + 1, two_count]
      ?2, [one_count, two_count] -> [one_count, two_count + 1]
      _, acc -> acc
    end)
    |> Enum.reduce(&Kernel.*/2)
  end

  def part2(input, wide \\ 25, tall \\ 6) do
    input
    |> to_charlist()
    |> parse_layers(wide, tall)
    |> Enum.reduce(fn layer, acc ->
      acc
      |> Stream.zip(layer)
      |> Enum.map(fn
        {?2, digit} -> digit
        {digit, _} -> digit
      end)
    end)
    |> Stream.map(fn
      ?0 -> ?\s
      _ -> ?*
    end)
    |> Stream.chunk_every(wide)
    |> Enum.join("\n")
  end

  def parse_layers(digits, wide, tall) do
    digits
    |> Stream.chunk_every(wide * tall)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day8Test do
      use ExUnit.Case
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day8.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day8.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
