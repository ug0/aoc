defmodule Aoc.Y2020.D12 do
  use Aoc.Input

  @start %{ship: {0, 0}, waypoint: {1, 0}}
  def part1(str \\ nil) do
    (str || input())
    |> parse_instructions()
    |> Enum.reduce(@start, &execute_instruction(&2, &1, move_target: :ship))
    |> mahattan_distance(@start)
    |> IO.inspect()
  end

  @start %{ship: {0, 0}, waypoint: {10, 1}}
  def part2(str \\ nil) do
    (str || input())
    |> parse_instructions()
    |> Enum.reduce(@start, &execute_instruction(&2, &1, move_target: :waypoint))
    |> mahattan_distance(@start)
    |> IO.inspect()
  end

  defp mahattan_distance(%{ship: {x1, y1}}, %{ship: {x2, y2}}) do
    abs(x2 - x1) + abs(y2 - y1)
  end

  defp execute_instruction(ship, instruction, opts) do
    target = Keyword.fetch!(opts, :move_target)

    case instruction do
      {?F, units} -> forward_ship(ship, units)
      {action, units} when action in 'NSEW' -> move_target(ship, target, get_vector(action), units)
      {action, degrees} when action in 'LR' -> rotate_waypoint(ship, get_vector(action), degrees)
    end
  end

  defp forward_ship(ship, units) do
    move_target(ship, :ship, ship.waypoint, units)
  end

  defp move_target(ship, target, vector, units) do
    Map.update!(ship, target, &move(&1, vector, units))
  end

  defp rotate_waypoint(%{waypoint: waypoint} = ship, vector, degrees) do
    %{ship | waypoint: turn(waypoint, vector, degrees)}
  end

  defp move({x, y}, {i, j}, units), do: {x + i * units, y + j * units}

  defp turn({x, y}, {_cos, _sin}, 0), do: {x, y}
  defp turn({x, y}, {cos, sin}, degrees), do: turn({x * cos - y * sin, x * sin + y * cos}, {cos, sin}, degrees - 90)

  defp get_vector(?N), do: {0, 1}
  defp get_vector(?S), do: {0, -1}
  defp get_vector(?E), do: {1, 0}
  defp get_vector(?W), do: {-1, 0}
  defp get_vector(?L), do: {0, 1}
  defp get_vector(?R), do: {0, -1}

  defp parse_instructions(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Enum.map(fn <<action::8, num::binary>> -> {action, String.to_integer(num)} end)
  end
end
