defmodule Day20 do
  alias __MODULE__.Maze

  def part1(str) do
    maze = Maze.from_text(str)

    Maze.shortest_distance(maze, maze.start, maze.end)
  end

  def part2(str) do
  end

  defmodule Maze do
    defstruct [:map, :portals, :graph, :start, :end]

    def from_text(str) do
      map = parse_map(str)
      portals = parse_portals(map)
      graph = parse_graph(map, portals)
      {start_coord, _} = portals |> Enum.find(&(elem(&1, 1) == 'AA'))
      {end_coord, _} = portals |> Enum.find(&(elem(&1, 1) == 'ZZ'))

      %__MODULE__{
        map: map,
        portals: portals,
        graph: graph,
        start: start_coord,
        end: end_coord
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
            [{coord, steps}]
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

    defp parse_portals(map) do
      Enum.reduce(map, %{}, fn
        {coord, ?.}, portals ->
          case portals do
            %{^coord => _} -> portals
            _ -> update_portals(portals, map, coord)
          end

        _, portals ->
          portals
      end)
    end

    defp update_portals(portals, map, coord) do
      case find_portal(map, coord) do
        nil -> portals
        label -> Map.put(portals, coord, label)
      end
    end

    defp find_portal(map, coord) do
      coord
      |> adjacents()
      |> Stream.map(&{&1, Map.get(map, &1)})
      |> Enum.find(&(elem(&1, 1) in ?A..?Z))
      |> case do
        nil ->
          nil

        {coord1, letter1} ->
          {coord2, letter2} =
            coord1
            |> adjacents()
            |> Stream.map(&{&1, Map.get(map, &1)})
            |> Enum.find(&(elem(&1, 1) in ?A..?Z))

          if coord1 < coord2 do
            [letter1, letter2]
          else
            [letter2, letter1]
          end
      end
    end

    defp parse_graph(map, portals) do
      portals
      |> Stream.map(fn {coord, label} ->
        {
          coord,
          case Enum.find(portals, fn {c, l} -> c != coord and l == label end) do
            nil -> find_reachable_portals(map, portals, coord)
            {c, _} -> [{c, 1} | find_reachable_portals(map, portals, coord)]
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
