defmodule Aoc.Y2020.D04 do
  use Aoc.Input

  def part1(str \\ nil) do
    (str || input())
    |> String.splitter("\n\n", trim: true)
    |> Stream.map(&parse_passport/1)
    |> Enum.count(&valid_passport?(&1, loose_rules()))
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> String.splitter("\n\n", trim: true)
    |> Stream.map(&parse_passport/1)
    |> Enum.count(&valid_passport?(&1, strict_rules()))
    |> IO.inspect()
  end

  def valid_passport?(passport, rules) do
    Enum.all?(rules, fn {field, rule} -> rule.(passport[field]) end)
  end

  def parse_passport(str) do
    str
    |> String.split(~r/\s/, trim: true)
    |> Enum.into(%{}, fn s ->
      s |> String.split(":") |> List.to_tuple()
    end)
  end

  @required_fields [
    # (Birth Year)
    "byr",
    # (Issue Year)
    "iyr",
    # (Expiration Year)
    "eyr",
    # (Height)
    "hgt",
    # (Hair Color)
    "hcl",
    # (Eye Color)
    "ecl",
    # (Passport ID)
    "pid"
    # (Country ID) (optional)
    # "cid"
  ]

  defp loose_rules do
    Enum.map(@required_fields, fn field ->
      {field, & &1}
    end)
  end

  defp strict_rules do
    Enum.map(@required_fields, fn field ->
      {field, gen_rule(field)}
    end)
  end

  defp gen_rule(field) do
    case field do
      "byr" -> fn value -> value && in_range(value, 1920, 2002) end
      "iyr" -> fn value -> value && in_range(value, 2010, 2020) end
      "eyr" -> fn value -> value && in_range(value, 2020, 2030) end
      "hgt" -> fn value -> value && validate_height(value) end
      "hcl" -> fn value -> value && validate_hair_color(value) end
      "ecl" -> fn value -> value && validate_eye_color(value) end
      "pid" -> fn value -> value && validate_pid(value) end
    end
  end

  defp in_range(str, from, to) when is_binary(str) do
    str |> String.to_integer() |> in_range(from, to)
  end

  defp in_range(num, from, to) when is_integer(num) do
    num in from..to
  end

  defp validate_height(value) do
    case Integer.parse(value) do
      {h, "cm"} when h in 150..193 -> true
      {h, "in"} when h in 59..76 -> true
      _ -> false
    end
  end

  defp validate_hair_color(color) do
    String.match?(color, ~r/^#[0-9a-f]{6}$/)
  end

  defp validate_eye_color(color) do
    color in ~w[amb blu brn gry grn hzl oth]
  end

  defp validate_pid(pid) do
    String.match?(pid, ~r/^[0-9]{9}$/)
  end
end
