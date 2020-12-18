defmodule Aoc.Y2020.D17 do
  use Aoc.Input

  defmodule Cubes do
    defstruct [:active_set, :range]

    @active ?#
    @inactive ?.

    def new(coords, dimension \\ 3) do
      coords =
        Enum.map(coords, fn {coord, state} ->
          {expand_coord_dimension(coord, dimension), state}
        end)

      range =
        Enum.map(0..(dimension - 1), fn i ->
          {{min, _}, {max, _}} = Enum.min_max_by(coords, fn {coord, _} -> elem(coord, i) end)
          elem(min, i)..elem(max, i)
        end)

      active_set =
        coords
        |> Stream.filter(fn {_, state} -> state == @active end)
        |> Stream.map(fn {coord, _} -> coord end)
        |> MapSet.new()

      %__MODULE__{active_set: active_set, range: range}
    end

    defp expand_coord_dimension(coord, dimension) do
      case tuple_size(coord) do
        ^dimension -> coord
        n when n < dimension -> coord |> Tuple.append(0) |> expand_coord_dimension(dimension)
      end
    end

    def active_state_count(%__MODULE__{active_set: set}) do
      MapSet.size(set)
    end

    def cycle(%__MODULE__{} = cubes, 0) do
      cubes
    end

    def cycle(%__MODULE__{} = cubes, times) do
      cubes
      |> scale(1)
      |> change_states()
      |> cycle(times - 1)
    end

    defp scale(%__MODULE__{range: range} = cubes, n) do
      %{cubes | range: Enum.map(range, fn min..max -> (min - n)..(max + n) end)}
    end

    defp change_states(%__MODULE__{} = cubes) do
      %{cubes | active_set: next_active_set(cubes)}
    end

    defp next_active_set(%__MODULE__{range: [x_range, y_range, z_range]} = cubes) do
      for x <- x_range, y <- y_range, z <- z_range, reduce: MapSet.new() do
        acc ->
          if next_state(cubes, coord = {x, y, z}) == @active do
            MapSet.put(acc, coord)
          else
            acc
          end
      end
    end

    defp next_active_set(%__MODULE__{range: [x_range, y_range, z_range, w_range]} = cubes) do
      for x <- x_range, y <- y_range, z <- z_range, w <- w_range, reduce: MapSet.new() do
        acc ->
          if next_state(cubes, coord = {x, y, z, w}) == @active do
            MapSet.put(acc, coord)
          else
            acc
          end
      end
    end

    defp next_state(%__MODULE__{active_set: set}, coord) do
      case {MapSet.member?(set, coord), active_neighbors_count(set, coord)} do
        {true, c} when c in 2..3 -> @active
        {true, _} -> @inactive
        {_, 3} -> @active
        _ -> @inactive
      end
    end

    defp active_neighbors_count(set, coord) do
      coord
      |> neighbors()
      |> Enum.count(&MapSet.member?(set, &1))
    end

    defp neighbors({x, y, z}) do
      for i <- -1..1, j <- -1..1, k <- -1..1, i != 0 or j != 0 or k != 0 do
        {x + i, y + j, z + k}
      end
    end

    defp neighbors({x, y, z, w}) do
      for i <- -1..1, j <- -1..1, k <- -1..1, l <- -1..1, i != 0 or j != 0 or k != 0 or l != 0 do
        {x + i, y + j, z + k, w + l}
      end
    end
  end

  alias Aoc.Y2020.D17.Cubes

  def part1(str \\ nil) do
    (str || input())
    |> parse_input()
    |> Cubes.new(3)
    |> Cubes.cycle(6)
    |> Cubes.active_state_count()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> parse_input()
    |> Cubes.new(4)
    |> Cubes.cycle(6)
    |> Cubes.active_state_count()
    |> IO.inspect()
  end

  defp parse_input(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> to_charlist()
      |> Stream.with_index()
      |> Enum.map(fn {state, x} ->
        {{x, y}, state}
      end)
    end)
    |> Enum.into(%{})
  end
end
