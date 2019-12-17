Code.load_file("../intcode_program.exs", __DIR__)

defmodule Day17 do
  alias IntcodeProgram, as: Program

  def part1(program) do
    program
    |> get_image()
    |> parse_image()
    |> sum_of_alignment_parameters()
  end

  def sum_of_alignment_parameters(map) do
    map
    |> intersections()
    |> Stream.map(fn {x, y} -> x * y end)
    |> Enum.sum()
  end

  def part2(program) do
    program
    |> get_image()
    |> parse_image()
    |> gen_walk_instructions()
    |> Enum.join(",")
    # |> IO.puts()
    # find out the path first, and then split it into function A, B, C instructions manually

    # 76,4,76,4,76,6,82,10,76,6, #A
    # 76,4,76,4,76,6,82,10,76,6, #A
    # 76,12,76,6,82,10,76,6,     #B
    # 82,8,82,10,76,6,           #C
    # 82,8,82,10,76,6,           #C
    # 76,4,76,4,76,6,82,10,76,6, #A
    # 82,8,82,10,76,6,           #C
    # 76,12,76,6,82,10,76,6,     #B
    # 82,8,82,10,76,6,           #C
    # 76,12,76,6,82,10,76,6      #B

    # ?A, ?A, ?B, ?C, ?C, ?A, ?C, ?B, ?C, ?B

    function_a = 'L,4,L,4,L,6,R,10,L,6\n'
    function_b = 'L,12,L,6,R,10,L,6\n'
    function_c = 'R,8,R,10,L,6\n'
    routine = 'A,A,B,C,C,A,C,B,C,B\n'
    feedback = 'n\n'
    inputs = routine ++ function_a ++ function_b ++ function_c ++ feedback

    camera = spawn_link(__MODULE__, :monitoring, [-1])

    program
    |> Program.new(spawn_link(__MODULE__, :control_movement, [inputs]), camera)
    |> Program.write(0, 2)
    |> Program.execute()

    send(camera, {:amount, self()})

    receive do
      amount -> amount
    end
  end

  def monitoring(output) when output > 128 do
    receive do
      {:amount, pid} -> send(pid, output)
    end
  end

  def monitoring(_) do
    receive do
      {:write_output, value} -> monitoring(value)
    end
  end

  def control_movement(instructions) do
    receive do
      {:read_input, robot} ->
        case instructions do
          [next | rest] ->
            send(robot, next)
            control_movement(rest)

          _ ->
            :no_instructions
        end
    end
  end

  def parse_image(raw_image) do
    raw_image
    |> to_string()
    |> String.splitter("\n", trim: true)
    |> Enum.with_index()
    |> Stream.flat_map(fn {row, y} ->
      row
      |> to_charlist()
      |> Stream.with_index()
      |> Enum.map(fn {point, x} -> {{x, y}, point} end)
    end)
    |> Enum.into(%{})
  end

  defp gen_walk_instructions(map) do
    gen_walk_instructions(map, {robot_location(map), {0, -1}}, [])
  end

  defp gen_walk_instructions(map, {position, direction}, instructions) do
    forward = move_forward(position, direction)
    left = move_forward(position, turn_left(direction))
    right = move_forward(position, turn_right(direction))

    case map do
      %{^forward => ?#} ->
        gen_walk_instructions(map, {forward, direction}, put_instruction(instructions, :forward))

      %{^left => ?#} ->
        gen_walk_instructions(
          map,
          {left, turn_left(direction)},
          put_instruction(instructions, :left)
        )

      %{^right => ?#} ->
        gen_walk_instructions(
          map,
          {right, turn_right(direction)},
          put_instruction(instructions, :right)
        )

      _ ->
        Enum.reverse(instructions)
    end
  end

  defp put_instruction([], :forward), do: [1]
  defp put_instruction([h | t], :forward), do: [h + 1 | t]
  defp put_instruction(instructions, :left), do: [1, ?L | instructions]
  defp put_instruction(instructions, :right), do: [1, ?R | instructions]

  defp turn_left({x, y}), do: {y, -x}
  defp turn_right({x, y}), do: {-y, x}

  defp move_forward({x, y}, {i, j}), do: {x + i, y + j}

  defp robot_location(map) do
    {coord, _} = Enum.find(map, &(elem(&1, 1) == ?^))
    coord
  end

  defp get_image(program) do
    camera = spawn_link(__MODULE__, :watching_robot, [[]])

    program
    |> Program.new(nil, camera)
    |> Program.execute()

    send(camera, {:image, self()})

    receive do
      raw_image ->
        raw_image
    end
  end

  defp intersections(map) do
    map
    |> Stream.filter(fn {coord, point} -> point == ?# and is_intersection?(map, coord) end)
    |> Enum.map(&elem(&1, 0))
  end

  defp is_intersection?(map, {x, y}) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
    |> Enum.all?(&(Map.get(map, &1) == ?#))
  end

  def watching_robot(image) do
    receive do
      {:write_output, value} ->
        watching_robot([value | image])

      {:image, pid} ->
        send(pid, Enum.reverse(image))
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day17Test do
      use ExUnit.Case

      @image """
             ..#..........
             ..#..........
             #######...###
             #.#...#...#.#
             #############
             ..#...#...#..
             ..#####...^..
             """
             |> to_charlist()
      test "part1" do
        assert @image |> Day17.parse_image() |> Day17.sum_of_alignment_parameters() == 76
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day17.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day17.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
