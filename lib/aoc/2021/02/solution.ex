defmodule Aoc.Y2021.D02 do
  use Aoc.Input

  def part1(str \\ nil) do
    {h, d} =
      (str || input())
      |> parse_commands()
      |> Enum.reduce({0, 0}, fn {x, y}, {h, d} ->
        {h + x, d + y}
      end)

    (h * d)
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    {h, d, _a} =
      (str || input())
      |> parse_commands()
      |> Enum.reduce({0, 0, 0}, fn {x, y}, {h, d, a} ->
        {h + x, d + a * x, a + y}
      end)

    (h * d)
    |> IO.inspect()
  end

  defp parse_commands(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Enum.map(&parse_command/1)
  end

  defp parse_command("forward " <> num) do
    {String.to_integer(num), 0}
  end

  defp parse_command("up " <> num) do
    {0, -String.to_integer(num)}
  end

  defp parse_command("down " <> num) do
    {0, String.to_integer(num)}
  end
end
