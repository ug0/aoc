defmodule Aoc.Y2020.D16 do
  use Aoc.Input

  def part1(str \\ nil) do
    {rules, _, nearby_tickets} = (str || input()) |> parse_input()

    nearby_tickets
    |> scanning_error_rate(rules)
    |> IO.inspect()
  end

  defp scanning_error_rate(tickets, rules) do
    tickets
    |> Stream.flat_map(fn ticket ->
      Enum.reject(ticket, fn value -> Enum.any?(rules, &valid_field?(value, &1)) end)
    end)
    |> Enum.sum()
  end

  def part2(str \\ nil) do
    {rules, my_ticket, nearby_tickets} = (str || input()) |> parse_input()

    rules
    |> parse_fields_order([my_ticket | filter_valid_tickets(nearby_tickets, rules)])
    |> Stream.zip(my_ticket)
    |> Stream.filter(fn {key, _} -> String.match?(key, ~r/^departure/) end)
    |> Stream.map(&elem(&1, 1))
    |> Enum.reduce(&Kernel.*/2)
    |> IO.inspect()
  end

  def parse_fields_order(rules, tickets) do
    tickets
    |> List.zip()
    |> Stream.map(&Tuple.to_list/1)
    |> Stream.map(&possible_fields(&1, rules))
    |> resolve_conflict_fields()
  end

  defp resolve_conflict_fields(fields) do
    if Enum.all?(fields, &(length(&1) == 1)) do
      List.flatten(fields)
    else
      taken =
        Enum.flat_map(fields, fn
          [key] -> [key]
          _ -> []
        end)

      fields
      |> Enum.map(fn
        [key] -> [key]
        keys -> keys -- taken
      end)
      |> resolve_conflict_fields()
    end
  end

  defp possible_fields([first | rest], rules) do
    Enum.reduce(rest, valid_fields_for_value(first, rules), fn field, valid_keys ->
      field |> valid_fields_for_value(rules) |> intersection(valid_keys)
    end)
  end

  defp intersection(list1, list2) do
    MapSet.intersection(MapSet.new(list1), MapSet.new(list2))
    |> MapSet.to_list()
  end

  defp valid_fields_for_value(value, rules) do
    rules
    |> Stream.filter(&valid_field?(value, &1))
    |> Enum.map(&elem(&1, 0))
  end

  defp filter_valid_tickets(tickets, rules) do
    Enum.filter(tickets, fn ticket ->
      Enum.all?(ticket, fn value -> Enum.any?(rules, &valid_field?(value, &1)) end)
    end)
  end

  defp valid_field?(value, {_, ranges}) do
    Enum.any?(ranges, &(value in &1))
  end

  defp parse_input(str) do
    [rules, "your ticket:\n" <> my_ticket, "nearby tickets:\n" <> nearby_tickets] =
      String.split(str, "\n\n", trim: true)

    {
      rules |> String.splitter("\n", trim: true) |> Enum.map(&parse_rule/1),
      parse_ticket(my_ticket),
      nearby_tickets |> String.splitter("\n", trim: true) |> Enum.map(&parse_ticket/1)
    }
  end

  defp parse_rule(str) do
    [key, ranges] = String.split(str, ": ")

    {key,
     ranges
     |> String.splitter(" or ")
     |> Enum.map(fn range ->
       [from, to] = range |> String.splitter("-") |> Enum.map(&String.to_integer/1)
       Range.new(from, to)
     end)}
  end

  defp parse_ticket(str) do
    str
    |> String.splitter(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
