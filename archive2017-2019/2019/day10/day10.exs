defmodule Day10 do
  def part1(input) do
    map = input |> parse_asteroids_map()

    map
    |> locations_with_visible_asteroids()
    |> Stream.map(fn {_, asteroids} -> length(asteroids) end)
    |> Enum.max()
  end

  def part2(input) do
    map = input |> parse_asteroids_map()

    {x, y} = the_nth_asteroid_to_be_vaporized(map, 200)
    x * 100 + y
  end

  def the_nth_asteroid_to_be_vaporized(map, n) do
    laser_location =
      map
      |> locations_with_visible_asteroids()
      |> Enum.max_by(fn {_, asteroids} -> length(asteroids) end)
      |> elem(0)

    the_nth_asteroid_to_be_vaporized(map, laser_location, n)
  end

  def the_nth_asteroid_to_be_vaporized(map, laser_location, n) do
    the_nth_asteroid_to_be_vaporized(map, laser_location, n, [])
  end

  defp the_nth_asteroid_to_be_vaporized(map, laser_location, n, [] = _current_round_targets) do
    next_round_targets =
      map
      |> visible_asteroids(laser_location)
      |> sort_clockwise(laser_location)

    the_nth_asteroid_to_be_vaporized(map, laser_location, n, next_round_targets)
  end

  defp the_nth_asteroid_to_be_vaporized(_map, _laser_location, 1, [target | _]) do
    target
  end

  defp the_nth_asteroid_to_be_vaporized(map, laser_location, n, [target | rest]) do
    map
    |> Map.put(target, ?.)
    |> the_nth_asteroid_to_be_vaporized(laser_location, n - 1, rest)
  end

  defp sort_clockwise(points, {x0, y0}) do
    points
    |> Enum.sort_by(fn {x, y} ->
      case :math.atan2(x - x0, y0 - y) * 180 / :math.pi() do
        theta when theta < 0 -> 360 + theta
        theta -> theta
      end
    end)
  end

  defp locations_with_visible_asteroids(map) do
    map
    |> Stream.filter(fn {_, type} -> type == ?# end)
    |> Stream.map(fn {coord, _} ->
      {coord, visible_asteroids(map, coord)}
    end)
  end

  defp visible_asteroids(map, location) do
    map
    |> Stream.filter(fn {coord, point} -> point == ?# and coord != location end)
    |> Enum.group_by(
      fn {coord, _} ->
        radian(coord, location)
      end,
      &elem(&1, 0)
    )
    |> Enum.map(fn {_, asteroids} ->
      Enum.min_by(asteroids, &distance(&1, location))
    end)
  end

  defp radian({x1, y1}, {x2, y2}) do
    :math.atan2(x1 - x2, y1 - y2)
  end

  defp distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def parse_asteroids_map(input) do
    input
    |> String.split("\n", trim: true)
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

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day10Test do
      use ExUnit.Case

      test "part1" do
        assert Day10.part1("""
               .#..#
               .....
               #####
               ....#
               ...##
               """) == 8

        assert Day10.part1("""
               ......#.#.
               #..#.#....
               ..#######.
               .#.#.###..
               .#..#.....
               ..#....#.#
               #..#....#.
               .##.#..###
               ##...#..#.
               .#....####
               """) == 33

        assert Day10.part1("""
               #.#...#.#.
               .###....#.
               .#....#...
               ##.#.#.#.#
               ....#.#.#.
               .##..###.#
               ..#...##..
               ..##....##
               ......#...
               .####.###.
               """) == 35

        assert Day10.part1("""
               .#..#..###
               ####.###.#
               ....###.#.
               ..###.##.#
               ##.##.#.#.
               ....###..#
               ..#.#..#.#
               #..#.#.###
               .##...##.#
               .....#.#..
               """) == 41

        assert Day10.part1("""
               .#..##.###...#######
               ##.############..##.
               .#.######.########.#
               .###.#######.####.#.
               #####.##.#.##.###.##
               ..#####..#.#########
               ####################
               #.####....###.#.#.##
               ##.#################
               #####.##.###..####..
               ..######..##.#######
               ####.##.####...##..#
               .#####..#.######.###
               ##...#.##########...
               #.##########.#######
               .####.#.###.###.#.##
               ....##.##.###..#####
               .#.#.###########.###
               #.#.#.#####.####.###
               ###.##.####.##.#..##
               """) == 210
      end

      @input """
      .#..##.###...#######
      ##.############..##.
      .#.######.########.#
      .###.#######.####.#.
      #####.##.#.##.###.##
      ..#####..#.#########
      ####################
      #.####....###.#.#.##
      ##.#################
      #####.##.###..####..
      ..######..##.#######
      ####.##.####...##..#
      .#####..#.######.###
      ##...#.##########...
      #.##########.#######
      .####.#.###.###.#.##
      ....##.##.###..#####
      .#.#.###########.###
      #.#.#.#####.####.###
      ###.##.####.##.#..##
      """
      test "part2" do
        map = Day10.parse_asteroids_map(@input)
        assert Day10.the_nth_asteroid_to_be_vaporized(map, 1) == {11, 12}
        assert Day10.the_nth_asteroid_to_be_vaporized(map, 2) == {12, 1}
        assert Day10.the_nth_asteroid_to_be_vaporized(map, 3) == {12, 2}
        assert Day10.the_nth_asteroid_to_be_vaporized(map, 10) == {12, 8}
        assert Day10.the_nth_asteroid_to_be_vaporized(map, 20) == {16, 0}
        assert Day10.the_nth_asteroid_to_be_vaporized(map, 50) == {16, 9}
        assert Day10.the_nth_asteroid_to_be_vaporized(map, 100) == {10, 16}
        assert Day10.the_nth_asteroid_to_be_vaporized(map, 199) == {9, 6}
        assert Day10.the_nth_asteroid_to_be_vaporized(map, 200) == {8, 2}
        assert Day10.the_nth_asteroid_to_be_vaporized(map, 201) == {10, 9}
        assert Day10.the_nth_asteroid_to_be_vaporized(map, 299) == {11, 1}
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day10.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day10.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
