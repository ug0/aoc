defmodule Aoc.Y2020.D19 do
  use Aoc.Input

  def part1(str \\ nil) do
    {rules, messages} = (str || input()) |> parse_input()

    messages
    |> Enum.map(&validate_rule(rules, 0, &1))
    |> Stream.filter(fn
      {true, ""} -> true
      _ -> false
    end)
    |> Enum.count()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    {rules, messages} = (str || input()) |> parse_input()

    rules = %{
      rules
      | 8 => {:loop, Stream.unfold(1, fn n -> {List.duplicate(42, n), n + 1} end)},
        11 => {:loop, Stream.unfold(1, fn n -> {List.duplicate(42, n) ++ List.duplicate(31, n), n + 1} end)}
    }

    messages
    |> Enum.map(&validate_rule(rules, 0, &1))
    |> Stream.filter(fn
      {true, ""} -> true
      _ -> false
    end)
    |> Enum.count()
    |> IO.inspect()
  end

  def validate_rule(_rules, [], str) do
    {true, str}
  end

  def validate_rule(rules, [i | sub_rules], str) do
    case validate_rule(rules, i, str) do
      {true, rest} ->
        validate_rule(rules, sub_rules, rest)

      results when is_list(results) ->
        results
        |> Stream.map(fn {true, rest} -> validate_rule(rules, sub_rules, rest) end)
        |> Enum.find({false, str}, fn {flag, _} -> flag end)

      result ->
        result
    end
  end

  def validate_rule(rules, i, str) when is_integer(i) do
    case rules[i] do
      <<letter>> ->
        case str do
          <<^letter, rest::binary>> -> {true, rest}
          _ -> {false, str}
        end

      sub_rules when is_list(sub_rules) ->
        validate_rule(rules, sub_rules, str)

      {:any, group_of_sub_rules} ->
        group_of_sub_rules
        |> Stream.map(&validate_rule(rules, &1, str))
        |> Enum.find({false, str}, fn {flag, _} -> flag end)

      {:loop, sub_rules_generator} ->
        sub_rules_generator
        |> Stream.take(String.length(str))
        |> Stream.map(&validate_rule(rules, &1, str))
        |> Enum.filter(fn {flag, _} -> flag end)
    end
  end

  defp parse_input(str) do
    [rules_str, msg_str] = String.split(str, "\n\n", trim: true)

    {
      parse_rules(rules_str),
      String.split(msg_str, "\n", trim: true)
    }
  end

  defp parse_rules(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Stream.map(fn line ->
      [i, rule] = String.split(line, ": ")
      {String.to_integer(i), parse_rule(rule)}
    end)
    |> Enum.into(%{})
  end

  defp parse_rule(str) do
    case String.split(str, " | ") do
      [<<?", letter, ?">>] when letter in ?a..?z ->
        <<letter>>

      [sub_rules] ->
        parse_sub_rules(sub_rules)

      group_of_sub_rules ->
        {:any, Enum.map(group_of_sub_rules, &parse_sub_rules/1)}
    end
  end

  defp parse_sub_rules(str) do
    str |> String.splitter(" ") |> Enum.map(&String.to_integer/1)
  end
end
