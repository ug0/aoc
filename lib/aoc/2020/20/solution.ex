defmodule Aoc.Y2020.D20 do
  use Aoc.Input

  def part1(str \\ nil) do
    (str || input())
    |> parse_tiles()
    |> find_four_corners()
    |> Enum.reduce(&Kernel.*/2)
    |> IO.inspect()
  end

  defp find_four_corners(tiles) do
    tile_borders = tiles |> Enum.map(fn {id, tile} -> {id, borders(tile)} end)

    tile_borders
    |> Stream.reject(fn tile ->
      adjacents_count(tile_borders, tile) > 2
    end)
    |> Enum.map(fn {id, _} -> id end)
  end

  defp adjacents_count(list_of_borders, {id, borders}) do
    Enum.count(borders, fn border ->
      list_of_borders
      |> Stream.flat_map(fn
        {^id, _} -> []
        {_, borders} -> borders
      end)
      |> Enum.any?(&(&1 in [border, Enum.reverse(border)]))
    end)
  end

  defp borders([border0 | _] = tile) do
    border1 = Enum.at(tile, -1)
    [border2 | rest] = List.zip(tile)
    [border0, border1, Tuple.to_list(border2), rest |> Enum.at(-1) |> Tuple.to_list()]
  end

  defp parse_tiles(str) do
    str
    |> String.splitter("\n\n", trim: true)
    |> Enum.into(%{}, fn s ->
      ["Tile " <> id, tile] = String.split(s, ":\n")
      {String.to_integer(id), parse_tile(tile)}
    end)
  end

  defp parse_tile(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Enum.map(&to_charlist/1)
  end
end
