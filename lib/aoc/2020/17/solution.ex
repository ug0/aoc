defmodule Aoc.Y2020.D17 do
  use Aoc.Input

  defmodule Cubes do
    defstruct [:coords, :range]

    @active ?#
    @inactive ?.

    def new(coords, dimension \\ 3) do
      coords =
        Enum.into(coords, %{}, fn {coord, state} ->
          {expand_coord_dimension(coord, dimension), state}
        end)

      range =
        Enum.map(0..(dimension - 1), fn i ->
          {{min, _}, {max, _}} = Enum.min_max_by(coords, fn {coord, _} -> elem(coord, i) end)
          elem(min, i)..elem(max, i)
        end)

      %__MODULE__{coords: coords, range: range}
    end

    defp expand_coord_dimension(coord, dimension) do
      case tuple_size(coord) do
        ^dimension -> coord
        n when n < dimension -> coord |> Tuple.append(0) |> expand_coord_dimension(dimension)
      end
    end

    def active_state_count(%__MODULE__{coords: coords}) do
      Enum.count(coords, fn {_, state} -> state == @active end)
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

    defp change_states(%__MODULE__{range: range} = cubes) do
      %{cubes | coords: coords_within_range(range, &next_state(cubes, &1))}
    end

    defp coords_within_range([x_range, y_range, z_range], state_fun) do
      for x <- x_range, y <- y_range, z <- z_range, into: %{} do
        {{x, y, z}, state_fun.({x, y, z})}
      end
    end

    defp coords_within_range([x_range, y_range, z_range, w_range], state_fun) do
      for x <- x_range, y <- y_range, z <- z_range, w <- w_range, into: %{} do
        {{x, y, z, w}, state_fun.({x, y, z, w})}
      end
    end

    defp next_state(%__MODULE__{coords: coords}, coord) do
      case {coords[coord], active_neighbors_count(coords, coord)} do
        {@active, c} when c in 2..3 -> @active
        {@active, _} -> @inactive
        {_, 3} -> @active
        _ -> @inactive
      end
    end

    defp active_neighbors_count(coords, coord) do
      coord
      |> neighbors()
      |> Stream.map(&coords[&1])
      |> Enum.count(&(&1 == @active))
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
