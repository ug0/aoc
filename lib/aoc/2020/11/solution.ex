defmodule Aoc.Y2020.D11 do
  use Aoc.Input

  defmodule SeatsGrid do
    def new(str) do
      parse_seats(str)
    end

    def occupied_count(grid) do
      Enum.count(grid, fn {_, state} -> state == ?# end)
    end

    def final_iteration(grid, change_rule) do
      new_grid = next_iteration(grid, change_rule)

      if new_grid == grid do
        new_grid
      else
        final_iteration(new_grid, change_rule)
      end
    end

    def next_iteration(grid, change_rule) do
      Enum.into(grid, %{}, fn {coord, state} -> {coord, change_rule.(grid, coord, state)} end)
    end

    def change_rule(:part1) do
      fn
        grid, coord, ?L ->
          if adjacent_occupied_count(grid, coord) == 0, do: ?#, else: ?L

        grid, coord, ?# ->
          if adjacent_occupied_count(grid, coord) >= 4, do: ?L, else: ?#

        _, _, state ->
          state
      end
    end

    def change_rule(:part2) do
      fn
        grid, coord, ?L ->
          if visible_occupied_count(grid, coord) == 0, do: ?#, else: ?L

        grid, coord, ?# ->
          if visible_occupied_count(grid, coord) >= 5, do: ?L, else: ?#

        _, _, state ->
          state
      end
    end

    defp adjacent_occupied_count(grid, coord) do
      grid
      |> adjacent_states(coord)
      |> Enum.count(&(&1 == ?#))
    end

    defp visible_occupied_count(grid, coord) do
      grid
      |> visible_states(coord)
      |> Enum.count(&(&1 == ?#))
    end

    defp adjacent_states(grid, coord) do
      adjacents() |> Enum.map(&grid[&1.(coord)])
    end

    defp visible_states(grid, coord) do
      adjacents() |> Enum.map(&first_see_state(grid, coord, &1))
    end

    defp first_see_state(grid, coord, direction) do
      next_coord = direction.(coord)
      case grid[next_coord] do
        ?. -> first_see_state(grid, next_coord, direction)
        state -> state
      end
    end

    defp adjacents do
      for i <- [-1, 0, 1], j <- [-1, 0, 1], i != 0 or j != 0 do
        fn {x, y} -> {x + i, y + j} end
      end
    end

    defp parse_seats(str) do
      str
      |> String.splitter("\n", trim: true)
      |> Stream.with_index()
      |> Stream.flat_map(fn {line, y} ->
        line
        |> to_charlist()
        |> Stream.with_index()
        |> Enum.map(fn {point, x} ->
          {{x, y}, point}
        end)
      end)
      |> Enum.into(%{})
    end
  end

  def part1(str \\ nil) do
    (str || input())
    |> SeatsGrid.new()
    |> SeatsGrid.final_iteration(SeatsGrid.change_rule(:part1))
    |> SeatsGrid.occupied_count()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> SeatsGrid.new()
    |> SeatsGrid.final_iteration(SeatsGrid.change_rule(:part2))
    |> SeatsGrid.occupied_count()
    |> IO.inspect()
  end
end
