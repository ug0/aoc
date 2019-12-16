Code.load_file("../intcode_program.exs", __DIR__)

defmodule Day15 do
  alias IntcodeProgram, as: Program

  def part1(input) do
    droid = spawn_link(__MODULE__, :find_oxygen_system, [%{{0, 0} => :seen}, {0, 0}, {0, 1}])

    input
    |> Program.new(droid, droid)
    |> Program.execute()
  end

  def part2(input) do
  end

  def find_oxygen_system(area, cursor, direction) do
    display(area, cursor)
    receive do
      {:read_input, remote} ->
        send_move_command(remote, direction)
        find_oxygen_system(area, cursor, direction)

      {:write_output, value} ->
        new_cursor = vec_add(cursor, direction)

        case value do
          _wall = 0 ->
            area
            |> Map.put(new_cursor, :wall)
            |> find_oxygen_system(cursor, next_move(area, cursor, direction))

          1 ->
            area
            |> Map.put(new_cursor, :seen)
            |> find_oxygen_system(new_cursor, direction)

          _dest = 2 ->
            IO.inspect(area)
        end
    end
  end

  defp send_move_command(remote, {0, 1}), do: send(remote, 1)
  defp send_move_command(remote, {0, -1}), do: send(remote, 2)
  defp send_move_command(remote, {-1, 0}), do: send(remote, 3)
  defp send_move_command(remote, {1, 0}), do: send(remote, 4)

  defp vec_add({x, y}, {i, j}) do
    {x + i, y + j}
  end

  defp display(area, droid) do
    points = Map.keys(area)
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(points, fn {x, _} -> x end)
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(points, fn {_, y} -> y end)

    max_y..min_y
    |> Enum.each(fn y ->
      min_x..max_x
      |> Enum.map(fn x ->
        case Map.get(area, {x, y}) do
          :wall ->
            ?#

          :seen ->
            ?.

          _ ->
            if {x, y} == droid do
              ?D
            else
              ?\s
            end
        end
      end)
      |> IO.puts()
    end)
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
