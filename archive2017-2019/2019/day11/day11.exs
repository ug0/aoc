Code.load_file("../intcode_program.exs", __DIR__)

defmodule Day11 do
  alias IntcodeProgram, as: Program

  def part1(input) do
    painting_process =
      spawn_link(__MODULE__, :painting_fun, [%{}, {{0, 0}, {0, 1}}, :painting, MapSet.new()])

    input
    |> Program.new(painting_process, painting_process)
    |> Program.execute()

    send(painting_process, {:painted_panels, self()})

    receive do
      painted -> MapSet.size(painted)
    end
  end

  def part2(input) do
    painting_process =
      spawn_link(__MODULE__, :painting_fun, [%{{0, 0} => 1}, {{0, 0}, {0, 1}}, :painting, MapSet.new()])

    input
    |> Program.new(painting_process, painting_process)
    |> Program.execute()

    send(painting_process, {:panels, self()})

    receive do
      panels -> print_panels(panels)
    end
  end

  def painting_fun(panels, {position, _} = robot, mode, painted) do
    receive do
      {:read_input, pid} ->
        send(pid, detect_color(panels, position))
        painting_fun(panels, robot, mode, painted)

      {:write_output, value} ->
        case mode do
          :painting ->
            panels
            |> paint_panel(position, value)
            |> painting_fun(robot, :moving, MapSet.put(painted, position))

          :moving ->
            painting_fun(panels, move_robot(robot, value), :painting, painted)
        end

      {:painted_panels, pid} ->
        send(pid, painted)

      {:panels, pid} ->
        send(pid, panels)
    end
  end

  defp detect_color(panels, position) do
    Map.get(panels, position, 0)
  end

  defp paint_panel(panel, position, color) do
    Map.put(panel, position, color)
  end

  defp move_robot({position, {x, y}}, _left = 0) do
    {vec_add(position, {-y, x}), {-y, x}}
  end

  defp move_robot({position, {x, y}}, _right = 1) do
    {vec_add(position, {y, -x}), {y, -x}}
  end

  defp vec_add({x, y}, {i, j}) do
    {x + i, y + j}
  end

  defp print_panels(panels) do
    points = Map.keys(panels)
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(points, fn {x, _} -> x end)
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(points, fn {_, y} -> y end)

    max_y..min_y
    |> Enum.each(fn y ->
      min_x..max_x
      |> Enum.map(fn x ->
        case Map.get(panels, {x, y}) do
          1 -> ?*
          _ -> ?\s
        end
      end)
      |> IO.puts()
    end)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day11Test do
      use ExUnit.Case
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day11.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day11.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
