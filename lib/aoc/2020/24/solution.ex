defmodule Aoc.Y2020.D24 do
  use Aoc.Input

  # Hexagonal grids: https://www.redblobgames.com/grids/hexagons/
  defmodule HexCoord do
    def move(coord, directions) when is_list(directions) do
      Enum.reduce(directions, coord, &move(&2, &1))
    end

    def move(coord, "e"), do: add(coord, {1, -1, 0})
    def move(coord, "w"), do: add(coord, {-1, 1, 0})
    def move(coord, "ne"), do: add(coord, {1, 0, -1})
    def move(coord, "nw"), do: add(coord, {0, 1, -1})
    def move(coord, "se"), do: add(coord, {0, -1, 1})
    def move(coord, "sw"), do: add(coord, {-1, 0, 1})

    def adjacents(coord) do
      for i <- -1..1, j <- -1..1, k <- -1..1, i + j + k == 0 and (i != 0 or j != 0 or k != 0) do
        add(coord, {i, j, k})
      end
    end

    defp add({x, y, z}, {i, j, k}), do: {x + i, y + j, z + k}
  end

  alias __MODULE__.HexCoord
  import Integer, only: [is_odd: 1]

  def part1(str \\ nil) do
    (str || input())
    |> parse_input()
    |> filter_black_tiles()
    |> MapSet.size()
    |> IO.inspect()
  end

  @days 100
  def part2(str \\ nil) do
    (str || input())
    |> parse_input()
    |> filter_black_tiles()
    |> after_days(@days)
    |> MapSet.size()
    |> IO.inspect()
  end

  @center {0, 0, 0}
  defp filter_black_tiles(directions) do
    directions
    |> Stream.map(&HexCoord.move(@center, &1))
    |> Enum.group_by(& &1)
    |> Stream.filter(fn {_, list} -> is_odd(length(list)) end)
    |> Stream.map(&elem(&1, 0))
    |> MapSet.new()
  end

  defp after_days(black_tiles, 0) do
    black_tiles
  end

  defp after_days(black_tiles, days) do
    black_tiles
    |> discover_new_tiles()
    |> Stream.filter(&(flip_color(black_tiles, &1) == :black))
    |> MapSet.new()
    |> after_days(days - 1)
  end

  defp discover_new_tiles(black_tiles) do
    black_tiles
    |> Stream.flat_map(&[&1 | HexCoord.adjacents(&1)])
    |> Stream.uniq()
  end

  defp flip_color(black_tiles, coord) do
    case {MapSet.member?(black_tiles, coord), count_black_adjacents(black_tiles, coord)} do
      {true, n} when n in [0, 3, 4, 5, 6] -> :white
      {true, _} -> :black
      {false, 2} -> :black
      _ -> :white
    end
  end

  defp count_black_adjacents(black_tiles, coord) do
    coord
    |> HexCoord.adjacents()
    |> Enum.count(&MapSet.member?(black_tiles, &1))
  end

  defp parse_input(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Enum.map(&parse_directions/1)
  end

  defp parse_directions(str) do
    parse_directions(str, [])
  end

  defp parse_directions("", acc) do
    Enum.reverse(acc)
  end

  defp parse_directions(<<d1, d2, rest::binary>>, acc) when d1 in 'sn' do
    parse_directions(rest, [<<d1, d2>> | acc])
  end

  defp parse_directions(<<d, rest::binary>>, acc) do
    parse_directions(rest, [<<d>> | acc])
  end
end
