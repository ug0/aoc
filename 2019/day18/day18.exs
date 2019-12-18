defmodule Day18 do
  def part1(input) do
    input
    |> parse_map()
    |> graph_of_shortest_distance_for_each_pair()
    |> find_shortest_distance()
  end

  defp find_shortest_distance(graph) do
    total_keys =
      graph
      |> Stream.flat_map(fn {{from, to}, _} -> [from, to] end)
      |> Stream.filter(&(&1 in ?a..?z))
      |> Stream.uniq()
      |> Enum.count()

    find_shortest_distance(:queue.from_list([{graph, '@', 0}]), total_keys, :infinity)
  end

  defp find_shortest_distance(queue, total_keys, min_distance) do
    case :queue.out(queue) do
      {:empty, _} ->
        min_distance

      {{:value, {_graph, _path, distance}}, rest} when distance > min_distance ->
        find_shortest_distance(rest, total_keys, min_distance)

      {{:value, {_graph, path, distance}}, rest} when length(path) - 1 == total_keys ->
        find_shortest_distance(rest, total_keys, distance)

      {{:value, {graph, path, distance}}, rest} ->
        new_queue =
          graph
          |> possible_next_moves(path, distance)
          |> Enum.reduce(rest, fn {_graph, _path, _distance} = state, acc ->
            :queue.in_r(state, acc)
          end)

        find_shortest_distance(new_queue, total_keys, min_distance)
    end
  end

  defp possible_next_moves(graph, [cursor | _] = path, distance) do
    graph
    |> Stream.filter(fn
      {{^cursor, _to}, {_moves, through_doors}} ->
        has_key_for_doors?(path, through_doors)

      _ ->
        false
    end)
    |> Enum.map(fn {{_, next_key}, {moves, _}} ->
      {remove_key_from_graph(graph, cursor), [next_key | path], moves + distance}
    end)
  end

  defp remove_key_from_graph(graph, key) do
    {edges_from_key, edges_to_key} =
      graph
      |> Stream.filter(fn {{from, to}, _} -> from == key or to == key end)
      |> Enum.split_with(fn {{from, _}, _} -> from == key end)

    new_edges =
      for {{_, to}, {distance1, doors1}} <- edges_from_key,
          {{from, _}, {distance2, doors2}} <- edges_to_key,
          from != to do
        {{from, to}, {distance1 + distance2, Enum.uniq(doors1 ++ doors2)}}
      end
      |> Stream.filter(fn {edge, {distance, _}} ->
        case graph do
          %{^edge => {d, _}} when d <= distance -> false
          _ -> true
        end
      end)
      |> Enum.into(%{})

    (edges_from_key ++ edges_to_key)
    |> Enum.reduce(graph, fn {edge, _}, acc ->
      Map.delete(acc, edge)
    end)
    |> Map.merge(new_edges)
  end

  defp has_key_for_doors?(keys, doors) do
    Enum.all?(doors, &((&1 + 32) in keys))
  end

  defp graph_of_shortest_distance_for_each_pair(map) do
    map
    |> Map.values()
    |> Stream.filter(&(&1 == ?@ or &1 in ?a..?z))
    |> Stream.flat_map(fn key ->
      {coord, _} = Enum.find(map, fn {_, area} -> area == key end)

      map
      |> nearby_keys(coord, MapSet.new([coord]))
      |> Enum.map(fn
        {new_key, moves, through_doors} -> {{key, new_key}, {moves, through_doors}}
      end)
    end)
    |> Enum.sort_by(fn {_, {moves, _}} -> moves end, &>=/2)
    |> Enum.into(%{})
  end

  defp nearby_keys(map, {x, y}, checked, distance \\ 0, through_doors \\ []) do
    [
      {-1, 0},
      {1, 0},
      {0, -1},
      {0, 1}
    ]
    |> Stream.map(fn {i, j} -> {x + i, y + j} end)
    |> Stream.reject(&MapSet.member?(checked, &1))
    |> Stream.flat_map(fn new_coord ->
      case map[new_coord] do
        new_key when new_key in ?a..?z ->
          [{new_key, distance + 1, through_doors}]

        door when door in ?A..?Z ->
          nearby_keys(map, new_coord, MapSet.put(checked, new_coord), distance + 1, [
            door | through_doors
          ])

        path when path in '@.' ->
          nearby_keys(map, new_coord, MapSet.put(checked, new_coord), distance + 1, through_doors)

        _ ->
          [:error]
      end
    end)
    |> Enum.filter(&(&1 != :error))
  end

  defp parse_map(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Stream.with_index()
    |> Stream.flat_map(fn {row, y} ->
      row
      |> to_charlist()
      |> Stream.with_index()
      |> Enum.map(fn {area, x} -> {{x, y}, area} end)
    end)
    |> Enum.reduce(%{}, fn
      {coord, area}, map -> Map.put(map, coord, area)
    end)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day18Test do
      use ExUnit.Case

      test "part1" do
        assert Day18.part1("""
               #########
               #b.A.@.a#
               #########
               """) == 8

        assert Day18.part1("""
               ########################
               #f.D.E.e.C.b.A.@.a.B.c.#
               ######################.#
               #d.....................#
               ########################
               """) == 86

        assert Day18.part1("""
               ########################
               #...............b.C.D.f#
               #.######################
               #.....@.a.B.c.d.A.e.F.g#
               ########################
               """) == 132

        # assert Day18.part1("""
        #        #################
        #        #i.G..c...e..H.p#
        #        ########.########
        #        #j.A..b...f..D.o#
        #        ########@########
        #        #k.E..a...g..B.n#
        #        ########.########
        #        #l.F..d...h..C.m#
        #        #################
        #        """) == 136

        assert Day18.part1("""
               ########################
               #@..............ac.GI.b#
               ###d#e#f################
               ###A#B#C################
               ###g#h#i################
               ########################
               """) == 81
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day18.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day18.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
