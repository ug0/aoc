defmodule Aoc.Y2020.D21 do
  use Aoc.Input

  def part1(str \\ nil) do
    list = (str || input()) |> parse_input()
    set = filter_allergens(list)

    list
    |> Stream.map(fn {ingredients, _} ->
      Enum.count(ingredients, &(not MapSet.member?(set, &1)))
    end)
    |> Enum.sum()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    list = (str || input()) |> parse_input()

    list
    |> dangerous_ingredients()
    |> Enum.join(",")
    |> IO.inspect()
  end

  defp filter_allergens(list) do
    list
    |> allergens_with_possible_ingredients()
    |> Stream.map(&elem(&1, 1))
    |> Enum.reduce(&MapSet.union/2)
  end

  defp dangerous_ingredients(list) do
    list
    |> allergens_with_possible_ingredients()
    |> remove_conflict_ingredients()
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.flat_map(fn {_, set} -> MapSet.to_list(set) end)
  end

  defp remove_conflict_ingredients(list) do
    remove_conflict_ingredients([], list)
  end

  defp remove_conflict_ingredients(sorted, []) do
    sorted
  end

  defp remove_conflict_ingredients(sorted, unsorted) do
    ingredients = sorted |> Stream.flat_map(&elem(&1, 1)) |> MapSet.new()

    {new_sorted, new_unsorted} =
      unsorted
      |> Stream.map(fn {allergen, set} -> {allergen, MapSet.difference(set, ingredients)} end)
      |> Enum.split_with(fn {_, set} -> MapSet.size(set) == 1 end)

    remove_conflict_ingredients(new_sorted ++ sorted, new_unsorted)
  end

  defp allergens_with_possible_ingredients(list) do
    list
    |> Stream.flat_map(fn {ingredients, allergens} ->
      Enum.map(allergens, &{&1, MapSet.new(ingredients)})
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Stream.map(fn {allergen, ingredients_set} ->
      {allergen, Enum.reduce(ingredients_set, &MapSet.intersection/2)}
    end)
  end

  defp parse_input(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Enum.map(fn line ->
      [ingredients, allergens] = String.split(line, " (contains ")

      {
        String.split(ingredients),
        allergens |> String.trim_trailing(")") |> String.split(", ")
      }
    end)
  end
end
