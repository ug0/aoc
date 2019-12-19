Code.load_file("../intcode_program.exs", __DIR__)

defmodule Day15 do
  alias IntcodeProgram, as: Program

  @starting_point {0, 0}
  def part1(input) do
    droid =
      spawn_link(__MODULE__, :find_oxygen_system, [
        %{@starting_point => :road},
        @starting_point,
        {0, 1}
      ])

    input
    |> Program.new(droid, droid)
    |> Program.execute()
  end

  def part2(input) do
    droid =
      spawn_link(__MODULE__, :explore_area, [%{@starting_point => :road}, @starting_point, {0, 1}])

    input
    |> Program.new(droid, droid)
    |> Program.execute()
  end

  def explore_area(area_map, cursor, direction) do
    IO.inspect({cursor, direction})
    receive do
      {:read_input, remote} ->
        send_move_command(remote, direction)
        explore_area(area_map, cursor, direction)

      {:write_output, value} ->
        new_cursor = vec_add(cursor, direction)

        case value do
          _wall = 0 ->
            area_map
            |> Map.put(new_cursor, :wall)
            |> explore_area(cursor, next_move(area_map, cursor, direction))

          1 ->
            case new_cursor do
              @starting_point ->
                :done
                |> IO.inspect()

              _ ->
                area_map
                |> Map.put(new_cursor, :road)
                |> explore_area(new_cursor, direction)
            end

          _target = 2 ->
            area_map
            |> Map.put(new_cursor, :oxygen_system)
            |> explore_area(new_cursor, direction)
        end
    end
  end

  def find_oxygen_system(area_map, cursor, direction) do
    receive do
      {:read_input, remote} ->
        send_move_command(remote, direction)
        find_oxygen_system(area_map, cursor, direction)

      {:write_output, value} ->
        new_cursor = vec_add(cursor, direction)

        case value do
          _wall = 0 ->
            area_map
            |> Map.put(new_cursor, :wall)
            |> find_oxygen_system(cursor, random_move(area_map, cursor, direction))

          1 ->
            area_map
            |> Map.put(new_cursor, :road)
            |> find_oxygen_system(new_cursor, direction)

          _target = 2 ->
            area_map
            |> Map.put(new_cursor, :oxygen_system)
            |> display({0, 0})
            |> fewest_moves_to_oxygen_system({0, 0})
            |> IO.inspect()

            Process.exit(self(), :kill)
        end
    end
  end

  defp fewest_moves_to_oxygen_system(map, from) do
    {to, _} = Enum.find(map, &(elem(&1, 1) == :oxygen_system))

    map
    |> shortest_path(from, to)
    |> length()
  end

  defp shortest_path(map, from, to) do
    map
    |> find_paths(from, to, nil, [])
    |> Enum.min_by(&length/1)
  end

  defp find_paths(_map, to, to, _prev, path) do
    [path]
  end

  defp find_paths(map, {x, y} = from, to, prev, path) do
    [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1}
    ]
    |> Stream.reject(&(&1 == prev))
    |> Stream.filter(&(map[&1] in [:road, :oxygen_system]))
    |> Enum.flat_map(fn coord ->
      find_paths(map, coord, to, from, [coord | path])
    end)
  end

  defp next_move(area_map, cursor, direction) do
    case {
      # right
      area_map[vec_add(cursor, turn_right(direction))],
      # forward
      area_map[vec_add(cursor, direction)],
      # left
      area_map[vec_add(cursor, turn_left(direction))]
    } do
      {:wall, :wall, _} -> turn_left(direction)
      {:wall, _, _} -> direction
      _ -> turn_right(direction)
    end
  end

  defp turn_left({x, y}), do: {-y, x}
  defp turn_right({x, y}), do: {y, -x}

  defp random_move(area_map, cursor, _) do
    [
      {0, 1},
      {0, -1},
      {1, 0},
      {-1, 0}
    ]
    |> Enum.filter(fn v -> area_map[vec_add(cursor, v)] != :wall end)
    |> Enum.random()
  end

  defp send_move_command(remote, {0, 1}), do: send(remote, 1)
  defp send_move_command(remote, {0, -1}), do: send(remote, 2)
  defp send_move_command(remote, {-1, 0}), do: send(remote, 3)
  defp send_move_command(remote, {1, 0}), do: send(remote, 4)

  defp vec_add({x, y}, {i, j}) do
    {x + i, y + j}
  end

  defp display(area_map, droid) do
    points = Map.keys(area_map)
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(points, fn {x, _} -> x end)
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(points, fn {_, y} -> y end)

    max_y..min_y
    |> Enum.each(fn y ->
      min_x..max_x
      |> Enum.map(fn x ->
        if {x, y} == droid do
          ?D
        else
          case Map.get(area_map, {x, y}) do
            :wall ->
              ?#

            :road ->
              ?.

            :oxygen_system ->
              ?O

            _ ->
              ?\s
          end
        end
      end)
      |> IO.puts()
    end)

    area_map
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day15Test do
      use ExUnit.Case
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day15.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day15.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
