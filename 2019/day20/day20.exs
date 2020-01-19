defmodule Day20 do
  alias __MODULE__.Maze

  def part1(str) do
    maze = Maze.from_text(str)

    Maze.shortest_distance(maze, {'AA', :outer}, {'ZZ', :outer})
  end

  def part2(str) do
  end

  defmodule Maze do
    defstruct [:map, :portals, :graph, :start, :end]

    def from_text(str) do
      map = parse_map(str)
      portals = parse_portals(map)
      graph = parse_graph(map, portals)

      %__MODULE__{
        map: map,
        portals: portals,
        graph: graph,
      }
    end

    def shortest_distance(%__MODULE__{} = maze, from, to) do
      maze
      |> shortest_distance(from)
      |> Map.fetch!(to)
    end

    def shortest_distance(%__MODULE__{} = maze, from) do
      shortest_distance(maze, %{from => 0}, from, MapSet.new())
    end

    defp shortest_distance(%__MODULE__{} = maze, distances, current, visited) do
      distances =
        maze
        |> neighbors(current)
        |> Stream.reject(fn {coord, _} -> MapSet.member?(visited, coord) end)
        |> Stream.map(fn {coord, dis} -> {coord, distances[current] + dis} end)
        |> Enum.reduce(distances, fn {coord, dis}, acc ->
          if acc[coord] > dis do
            Map.put(acc, coord, dis)
          else
            acc
          end
        end)

      visited = MapSet.put(visited, current)

      distances
      |> Stream.reject(fn {coord, _} -> MapSet.member?(visited, coord) end)
      |> Enum.min_by(&elem(&1, 1), fn -> nil end)
      |> case do
        nil -> distances
        {next, _} -> shortest_distance(maze, distances, next, visited)
      end
    end

    def neighbors(%__MODULE__{graph: graph}, coord) do
      Map.fetch!(graph, coord)
    end

    defp find_reachable_portals(map, portals, coord) do
      find_reachable_portals(map, portals, coord, nil, 0)
    end

    defp find_reachable_portals(map, portals, coord, prev, steps) do
      case map[coord] do
        ?. ->
          if steps > 0 and portals[coord] do
            [{portals[coord], steps}]
          else
            coord
            |> adjacents()
            |> Stream.filter(&(&1 != prev and map[&1] == ?.))
            |> Enum.flat_map(&find_reachable_portals(map, portals, &1, coord, steps + 1))
          end

        _ ->
          []
      end
    end

    defp parse_map(str) do
      str
      |> String.splitter("\n", trim: true)
      |> Stream.with_index()
      |> Stream.flat_map(fn {row, y} ->
        row
        |> to_charlist()
        |> Stream.with_index()
        |> Enum.map(fn {tile, x} -> {{x, y}, tile} end)
      end)
      |> Enum.into(%{})
    end

    def parse_portals(map) do
      map
      |> Stream.filter(fn
        {coord, tile} when tile in ?A..?Z ->
          coord
          |> adjacents()
          |> Enum.any?(&(map[&1] == ?.))

        _ ->
          false
      end)
      |> Stream.map(fn {coord, tile} ->
        Enum.sort_by(
          [
            {coord, tile}
            | coord
              |> adjacents()
              |> Stream.map(&{&1, map[&1]})
              |> Enum.filter(fn {_, t} -> t == ?. or t in ?A..?Z end)
          ],
          &elem(&1, 0)
        )
        |> case do
          [{coord, ?.}, {coord1, letter1}, {coord2, letter2}] -> {coord, {[letter1, letter2], parse_portal_side(map, coord1, coord2)}}
          [{coord1, letter1}, {coord2, letter2}, {coord, ?.}] -> {coord, {[letter1, letter2], parse_portal_side(map, coord1, coord2)}}
        end
      end)
      |> Enum.into(%{})
    end

    defp parse_portal_side(map, {x, y}, {x, _}) do
      if Enum.count(map, fn {{_, j}, tile} -> j == y and tile in '.#' end) > 0 do
        :inner
      else
        :outer
      end
    end

    defp parse_portal_side(map, {x, y}, {_, y}) do
      if Enum.count(map, fn {{i, _}, tile} -> i == x and tile in '.#' end) > 0 do
        :inner
      else
        :outer
      end
    end

    defp parse_graph(map, portals) do
      portals
      |> Stream.map(fn {coord, {label, side} = portal} ->
        other_side = case side do
          :inner -> :outer
          :outer -> :inner
        end
        {
          portal,
          case portals[{label, other_side}] do
            nil -> find_reachable_portals(map, portals, coord)
            p -> [{p, 1} | find_reachable_portals(map, portals, coord)]
          end
        }
      end)
      |> Enum.into(%{})
    end

    defp adjacents({x, y}) do
      [
        {x + 1, y},
        {x - 1, y},
        {x, y + 1},
        {x, y - 1}
      ]
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day20Test do
      use ExUnit.Case

      @maze1 """
               A
               A
        #######.#########
        #######.........#
        #######.#######.#
        #######.#######.#
        #######.#######.#
        #####  B    ###.#
      BC...##  C    ###.#
        ##.##       ###.#
        ##...DE  F  ###.#
        #####    G  ###.#
        #########.#####.#
      DE..#######...###.#
        #.#########.###.#
      FG..#########.....#
        ###########.#####
                   Z
                   Z
      """
      @maze2 """
                         A
                         A
        #################.#############
        #.#...#...................#.#.#
        #.#.#.###.###.###.#########.#.#
        #.#.#.......#...#.....#.#.#...#
        #.#########.###.#####.#.#.###.#
        #.............#.#.....#.......#
        ###.###########.###.#####.#.#.#
        #.....#        A   C    #.#.#.#
        #######        S   P    #####.#
        #.#...#                 #......VT
        #.#.#.#                 #.#####
        #...#.#               YN....#.#
        #.###.#                 #####.#
      DI....#.#                 #.....#
        #####.#                 #.###.#
      ZZ......#               QG....#..AS
        ###.###                 #######
      JO..#.#.#                 #.....#
        #.#.#.#                 ###.#.#
        #...#..DI             BU....#..LF
        #####.#                 #.#####
      YN......#               VT..#....QG
        #.###.#                 #.###.#
        #.#...#                 #.....#
        ###.###    J L     J    #.#.###
        #.....#    O F     P    #.#...#
        #.###.#####.#.#####.#####.###.#
        #...#.#.#...#.....#.....#.#...#
        #.#####.###.###.#.#.#########.#
        #...#.#.....#...#.#.#.#.....#.#
        #.###.#####.###.###.#.#.#######
        #.#.........#...#.............#
        #########.###.###.#############
                 B   J   C
                 U   P   P
      """
      test "part1" do
        assert Day20.part1(@maze1) == 23
        assert Day20.part1(@maze2) == 58
      end

      @maze3 """
                   Z L X W       C
                   Z P Q B       K
        ###########.#.#.#.#######.###############
        #...#.......#.#.......#.#.......#.#.#...#
        ###.#.#.#.#.#.#.#.###.#.#.#######.#.#.###
        #.#...#.#.#...#.#.#...#...#...#.#.......#
        #.###.#######.###.###.#.###.###.#.#######
        #...#.......#.#...#...#.............#...#
        #.#########.#######.#.#######.#######.###
        #...#.#    F       R I       Z    #.#.#.#
        #.###.#    D       E C       H    #.#.#.#
        #.#...#                           #...#.#
        #.###.#                           #.###.#
        #.#....OA                       WB..#.#..ZH
        #.###.#                           #.#.#.#
      CJ......#                           #.....#
        #######                           #######
        #.#....CK                         #......IC
        #.###.#                           #.###.#
        #.....#                           #...#.#
        ###.###                           #.#.#.#
      XF....#.#                         RF..#.#.#
        #####.#                           #######
        #......CJ                       NM..#...#
        ###.#.#                           #.###.#
      RE....#.#                           #......RF
        ###.###        X   X       L      #.#.#.#
        #.....#        F   Q       P      #.#.#.#
        ###.###########.###.#######.#########.###
        #.....#...#.....#.......#...#.....#.#...#
        #####.#.###.#######.#######.###.###.#.#.#
        #.......#.......#.#.#.#.#...#...#...#.#.#
        #####.###.#####.#.#.#.#.###.###.#.###.###
        #.......#.....#.#...#...............#...#
        #############.#.#.###.###################
                     A O F   N
                     A A D   M
      """
      test "part2" do
        # assert Day20.part2(@maze1) == 26
        # assert Day20.part2(@maze2) == :nopath
        # assert Day20.part2(@maze3) == 396
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day20.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day20.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
