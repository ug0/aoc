defmodule Day9 do
  def part1(input) do
    input
    |> remove_canceled()
    |> remove_garbage()
    |> parse_groups()
    |> calc_score()
  end

  def part2(input) do
    x = remove_canceled(input)
    y = remove_garbage(x)

    String.length(x) - String.length(y)
  end

  defp calc_score(groups) do
    calc_score(groups, 1)
  end

  defp calc_score([], acc) do
    acc
  end

  defp calc_score(groups, acc) do
    groups
    |> Stream.map(&calc_score(&1, acc + 1))
    |> Enum.sum()
    |> Kernel.+(acc)
  end

  defp parse_groups(str) do
    str
    |> simplify()
    |> String.replace("{", "[")
    |> String.replace("}", "]")
    |> Code.eval_string()
    |> elem(0)
  end

  defp remove_garbage(str) do
    str
    |> String.replace(~r/<[^>]*>/, "<>")
  end

  defp simplify(str) do
    str
    |> String.replace(~r/<>,?/, "")
    |> String.replace(~r/{[^{}]+},?/, "{}")
  end

  defp remove_canceled(str) do
    str
    |> to_charlist()
    |> remove_canceled([])
  end

  defp remove_canceled([], result) do
    result
    |> Enum.reverse()
    |> to_string()
  end

  defp remove_canceled([?!, _ | rest], result) do
    remove_canceled(rest, result)
  end

  defp remove_canceled([h | rest], result) do
    remove_canceled(rest, [h | result])
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day9Test do
      use ExUnit.Case

      test "part1 result" do
        Enum.each(
          [
            {"{}", 1},
            {"{{{}}}", 6},
            {"{{},{}}", 5},
            {"{{{},{},{{}}}}", 16},
            {"{<a>,<a>,<a>,<a>}", 1},
            {"{{<ab>},{<ab>},{<ab>},{<ab>}}", 9},
            {"{{<!!>},{<!!>},{<!!>},{<!!>}}", 9},
            {"{{<a!>},{<a!>},{<a!>},{<ab>}}", 3}
          ],
          fn {input, result} ->
            assert Day9.part1(input) == result
          end
        )
      end

      test "part2 result" do
        Enum.each(
          [
            {"<>", 0},
            {"<random characters>", 17},
            {"<<<<>", 3},
            {"<{!>}>", 2},
            {"<!!>", 0},
            {"<!!!>>", 0},
            {"<{o\"i!a,<{i<a>", 10}
          ],
          fn {input, result} ->
            assert Day9.part2(input) == result
          end
        )
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day9.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day9.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
