defmodule Day23 do
  def part1(input) do
    bots = input |> parse_bots()

    strongest_bot = Enum.max_by(bots, fn {_, radius} -> radius end)
    Enum.count(bots, &bot_in_range?(strongest_bot, &1))
  end

  def part2(input) do
    # possible solutions
    # https://en.wikipedia.org/wiki/Boolean_satisfiability_problem
    # https://en.wikipedia.org/wiki/Divide-and-conquer_algorithm
    # https://en.wikipedia.org/wiki/Octree

    bots = input |> parse_bots()

    {{{min_x, _, _}, _}, {{max_x, _, _}, _}} = Enum.min_max_by(bots, fn {{x, _, _}, _} -> x end)
    {{{_, min_y, _}, _}, {{_, max_y, _}, _}} = Enum.min_max_by(bots, fn {{_, y, _}, _} -> y end)
    {{{_, _, min_z}, _}, {{_, _, max_z}, _}} = Enum.min_max_by(bots, fn {{_, _, z}, _} -> z end)
    corner1 = {min_x, min_y, min_z}
    corner2 = {max_x, max_y, max_z}

    find_point_in_cube({corner1, corner2}, bots)
  end

  @zero_point {0, 0, 0}
  defp find_point_in_cube(cube = {_corner1, _corner2}, bots) do
    cond do
      smallest_cube?(cube) ->
        cube
        |> points_in_cube()
        |> Enum.sort_by(&manhattan_distance(&1, @zero_point))
        |> Enum.max_by(fn point ->
          bots
          |> Stream.filter(&in_bot_range?(&1, point))
          |> Enum.count()
        end)
        |> manhattan_distance(@zero_point)

      true ->
        cube
        |> split_cube()
        |> Enum.max_by(fn sub_cube ->
          bots
          |> Stream.filter(&in_bot_range?(&1, sub_cube))
          |> Enum.count()
        end)
        |> find_point_in_cube(bots) # OPTIMIZE deal with multiple maximums
    end
  end

  defp smallest_cube?({{x1, y1, z1}, {x2, y2, z2}}) do
    abs(x2 - x1) < 2 || abs(y2 - y1) < 2 || abs(z2 - z1) < 2
  end

  defp points_in_cube({{x1, y1, z1}, {x2, y2, z2}}) do
    for i <- x1..x2, j <- y1..y2, k <- z1..z2, do: {i, j, k}
  end

  defp split_cube({corner1 = {x1, y1, z1}, corner2 = {x2, y2, z2}}) do
    center_x = div(x2 + x1, 2)
    center_y = div(y2 + y1, 2)
    center_z = div(z2 + z1, 2)

    [
      {corner1, {center_x, center_y, center_z}},
      {{center_x, y1, z1}, {x2, center_y, center_z}},
      {{x1, center_y, z1}, {center_x, y2, center_z}},
      {{center_x, center_y, z1}, {x2, y2, center_z}},
      {{x1, y1, center_z}, {center_x, center_y, z2}},
      {{center_x, y1, center_z}, {x2, center_y, z2}},
      {{x1, center_y, center_z}, {center_x, y2, z2}},
      {{center_x, center_y, center_z}, corner2}
    ]
  end

  # one-point-cube
  defp in_bot_range?(bot, _cube = {corner, corner}) do
    in_bot_range?(bot, corner)
  end

  # bot is inside the cube
  defp in_bot_range?({{x, y, z}, _r}, {{x_min, y_min, z_min}, {x_max, y_max, z_max}})
       when x >= x_min and x <= x_max and y >= y_min and y <= y_max and z >= z_min and z <= z_max do
    true
  end

  # bot is outside of the cube
  defp in_bot_range?({{x, y, z}, _r} = bot, {{x_min, y_min, z_min}, {x_max, y_max, z_max}}) do
    cond do
      x >= x_min and x <= x_max and y >= y_min and y <= y_max ->
        in_bot_range?(bot, {x, y, Enum.min_by([z_min, z_max], &abs(&1 - z))})

      x >= x_min and x <= x_max and z >= z_min and z <= z_max ->
        in_bot_range?(bot, {x, Enum.min_by([y_min, y_max], &abs(&1 - y)), z})

      y >= y_min and y <= y_max and z >= z_min and z <= z_max ->
        in_bot_range?(bot, {Enum.min_by([x_min, x_max], &abs(&1 - x)), y, z})

      x >= x_min and x <= x_max ->
        in_bot_range?(
          bot,
          {x, Enum.min_by([y_min, y_max], &abs(&1 - y)),
           Enum.min_by([z_min, z_max], &abs(&1 - z))}
        )

      y >= y_min and y <= y_max ->
        in_bot_range?(
          bot,
          {Enum.min_by([x_min, x_max], &abs(&1 - x)), y,
           Enum.min_by([z_min, z_max], &abs(&1 - z))}
        )

      z >= z_min and z <= z_max ->
        in_bot_range?(
          bot,
          {Enum.min_by([x_min, x_max], &abs(&1 - x)),
           Enum.min_by([y_min, y_max], &abs(&1 - y)), z}
        )

      true ->
        for i <- [x_min, x_max], j <- [y_min, y_max], k <- [z_min, z_max] do
          {i, j, k}
        end
        |> Enum.any?(&in_bot_range?(bot, &1))
    end
  end

  defp in_bot_range?({coord1, radius}, coord2 = {_, _, _}) do
    manhattan_distance(coord1, coord2) <= radius
  end

  defp bot_in_range?(bot1, {coord2, _}), do: in_bot_range?(bot1, coord2)

  defp manhattan_distance({x1, y1, z1}, {x2, y2, z2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end

  defp parse_bots(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    ["pos=" <> coord, "r=" <> radius] = String.split(line, ", ")

    coord =
      coord
      |> String.split(~r/[^-0-9]/, trim: true)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()

    radius = String.to_integer(radius)

    {coord, radius}
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day23Test do
      use ExUnit.Case

      @input """
      pos=<0,0,0>, r=4
      pos=<1,0,0>, r=1
      pos=<4,0,0>, r=3
      pos=<0,2,0>, r=1
      pos=<0,5,0>, r=3
      pos=<0,0,3>, r=1
      pos=<1,1,1>, r=1
      pos=<1,1,2>, r=1
      pos=<1,3,1>, r=1
      """
      test "part 1 result" do
        assert Day23.part1(@input) == 7
      end

      @input """
      pos=<10,12,12>, r=2
      pos=<12,14,12>, r=2
      pos=<16,12,12>, r=4
      pos=<14,14,14>, r=6
      pos=<50,50,50>, r=200
      pos=<10,10,10>, r=5
      """
      test "part 2 result" do
        assert Day23.part2(@input) == 36
      end
    end

  [input, "--part1"] ->
    input
    |> File.read!()
    |> Day23.part1()
    |> IO.inspect()

  [input, "--part2"] ->
    input
    |> File.read!()
    |> Day23.part2()
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input_file]")
end
