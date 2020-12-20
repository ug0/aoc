defmodule Aoc.Y2020.D19 do
  use Aoc.Input

  def part1(str \\ nil) do
    {rules, messages} = (str || input()) |> parse_input()

    messages
    |> Enum.count(&match_rule?(rules, 0, &1))
    |> IO.inspect()
  end

  defp match_rule?(rules, i, str) do
    rules[i].(rules, str)
  end

  defp parse_rules() do
  end

  defp parse_input(str) do
    {rules_str, msg_str} = String.split(str, "\n\n", trim: true)
    {
      parse_rules(rules_str),
      String.split(msg_str, "\n", trim: true)
    }
  end
end
