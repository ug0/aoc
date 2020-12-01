Code.load_file("../intcode_program.exs", __DIR__)

defmodule Day15 do
  alias IntcodeProgram, as: Program

  @starting_point {0, 0}
  def part1(input) do
    input
    |> get_explored_area_map()
    |> fewest_moves_to_oxygen_system(@starting_point)
  end

  defp fewest_moves_to_oxygen_system(map, from) do
    {to, _} = Enum.find(map, &(elem(&1, 1) == :oxygen))

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
    |> Stream.filter(&(map[&1] in [:road, :oxygen]))
    |> Enum.flat_map(fn coord ->
      find_paths(map, coord, to, from, [coord | path])
    end)
  end

  def part2(input) do
    input
    |> get_explored_area_map()
    |> steps_to_fill_oxygen()
  end

  defp steps_to_fill_oxygen(area_map, steps \\ 0) do
    if full_with_oxygen?(area_map) do
      steps
    else
      area_map
      |> spread_oxygen()
      |> steps_to_fill_oxygen(steps + 1)
    end
  end

  defp spread_oxygen(area_map) do
    area_map
    |> Stream.filter(&(elem(&1, 1) == :oxygen))
    |> Stream.flat_map(fn {{x, y}, _} ->
      [
        {x + 1, y},
        {x - 1, y},
        {x, y + 1},
        {x, y - 1}
      ]
      |> Enum.filter(&(area_map[&1] == :road))
    end)
    |> Enum.reduce(area_map, fn coord, acc -> Map.put(acc, coord, :oxygen) end)
  end

  defp full_with_oxygen?(area_map) do
    Enum.count(area_map, &(elem(&1, 1) == :road)) == 0
  end

  defp get_explored_area_map(input) do
    droid =
      spawn_link(__MODULE__, :explore_area, [
        %{@starting_point => :road},
        {@starting_point, {0, 1}},
        {0, 1}
      ])

    Task.start_link(fn ->
      input
      |> Program.new(droid, droid)
      |> Program.execute()
    end)

    send(droid, {:area_map, self()})

    receive do
      area_map -> area_map
    end
  end

  def explore_area(area_map, :done) do
    receive do
      {:area_map, pid} -> send(pid, area_map)
    end
  end

  def explore_area(area_map, {cursor, direction} = current, next_move) do
    receive do
      {:read_input, remote} ->
        send_move_command(remote, next_move)
        explore_area(area_map, current, next_move)

      {:write_output, value} ->
        new_cursor = vec_add(cursor, next_move)

        case value do
          _wall = 0 ->
            area_map
            |> Map.put(new_cursor, :wall)
            |> explore_area({cursor, direction}, calc_next_move(area_map, cursor, direction))

          1 ->
            case new_cursor do
              @starting_point ->
                explore_area(area_map, :done)

              _ ->
                area_map
                |> Map.put(new_cursor, :road)
                |> explore_area(
                  {new_cursor, next_move},
                  calc_next_move(area_map, new_cursor, next_move)
                )
            end

          _target = 2 ->
            area_map
            |> Map.put(new_cursor, :oxygen)
            |> explore_area(
              {new_cursor, next_move},
              calc_next_move(area_map, new_cursor, next_move)
            )
        end
    end
  end

  defp calc_next_move(area_map, cursor, direction) do
    case {
      # right
      area_map[vec_add(cursor, turn_right(direction))],

      # forward
      area_map[vec_add(cursor, direction)],

      # left
      area_map[vec_add(cursor, turn_left(direction))]
    } do
      {:wall, :wall, :wall} -> direction |> turn_left() |> turn_left()
      {:wall, :wall, _} -> turn_left(direction)
      {:wall, _, _} -> direction
      _ -> turn_right(direction)
    end
  end

  defp turn_left({x, y}), do: {-y, x}
  defp turn_right({x, y}), do: {y, -x}

  defp send_move_command(remote, {0, 1}), do: send(remote, 1)
  defp send_move_command(remote, {0, -1}), do: send(remote, 2)
  defp send_move_command(remote, {-1, 0}), do: send(remote, 3)
  defp send_move_command(remote, {1, 0}), do: send(remote, 4)

  defp vec_add({x, y}, {i, j}), do: {x + i, y + j}

  def display(area_map, droid) do
    points = Map.keys(area_map)
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(points, fn {x, _} -> x end)
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(points, fn {_, y} -> y end)

    max_y..min_y
    |> Enum.each(fn y ->
      min_x..max_x
      |> Enum.map(fn x ->
        case {{x, y}, area_map[{x, y}]} do
          {@starting_point, _} -> ?S
          {^droid, _} -> ?D
          {_, :wall} -> ?#
          {_, :road} -> ?.
          {_, :oxygen} -> ?O
          _ -> ?\s
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
