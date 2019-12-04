defmodule Day4 do
  def part1(input) do
    input
    |> parse_input_range()
    |> Stream.filter(&probable_password?/1)
    |> Enum.count()
  end

  def probable_password?(num) when is_integer(num) do
    num |> Integer.digits() |> probable_password?()
  end

  def probable_password?(digits) when is_list(digits) do
    never_decrease?(digits) and has_same_adjacents?(digits)
  end

  def part2(input) do
    input
    |> parse_input_range()
    |> Stream.filter(&more_probable_password?/1)
    |> Enum.count()
  end

  def more_probable_password?(num) when is_integer(num) do
    num |> Integer.digits() |> more_probable_password?()
  end

  def more_probable_password?(digits) do
    never_decrease?(digits) and has_two_same_adjacents?(digits)
  end

  defp has_same_adjacents?([a, a | _]), do: true
  defp has_same_adjacents?([_ | rest]), do: has_same_adjacents?(rest)
  defp has_same_adjacents?(_), do: false

  defp has_two_same_adjacents?([a, a, b, _, _, _]) when a != b, do: true
  defp has_two_same_adjacents?([a, b, b, c | _]) when a != b and b != c, do: true
  defp has_two_same_adjacents?([a, b, b]) when a != b, do: true
  defp has_two_same_adjacents?([_ | rest]), do: has_two_same_adjacents?(rest)
  defp has_two_same_adjacents?(_), do: false

  defp never_decrease?([a, b, c, d, e, f]) when a <= b and b <= c and c <= d and d <= e and e <= f do
    true
  end

  defp never_decrease?(_) do
    false
  end

  defp parse_input_range(input) do
    [min, max] =
      input
      |> String.splitter("-")
      |> Enum.map(&String.to_integer/1)

    min..max
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day4Test do
      use ExUnit.Case

      test "probable password" do
        assert Day4.probable_password?(111_111)
        refute Day4.probable_password?(223_450)
        refute Day4.probable_password?(123_789)
      end

      test "more probable password" do
        assert Day4.more_probable_password?(112_233)
        refute Day4.more_probable_password?(123_444)
        assert Day4.more_probable_password?(111_122)
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day4.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day4.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
