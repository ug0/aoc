defmodule Cave do
  defstruct [:depth, :target, :cache]

  def new(depth, target) do
    %Cave{depth: depth, target: target, cache: :ets.new(__MODULE__, [:set, :protected])}
  end

  # part1
  def total_risk_level(%Cave{target: {max_x, max_y}} = cave) do
    Enum.reduce(0..max_y, 0, fn y, acc ->
      Enum.reduce(0..max_x, acc, fn x, total ->
        total + (cave |> region_type({x, y}) |> risk_level())
      end)
    end)
  end

  defp risk_level(:rocky), do: 0
  defp risk_level(:wet), do: 1
  defp risk_level(:narrow), do: 2

  def geo_index(_cave, {0, 0}), do: 0
  def geo_index(%Cave{target: target}, target), do: 0
  def geo_index(_cave, {x, 0}), do: x * 16807
  def geo_index(_cave, {0, y}), do: y * 48271

  def geo_index(cave, {x, y}), do: erosion_level(cave, {x - 1, y}) * erosion_level(cave, {x, y - 1})

  def erosion_level(cave = %Cave{cache: cache}, coord) do
    case :ets.lookup(cache, {:erosion_level, coord}) do
      [{_, level}] ->
        level

      [] ->
        level = calc_erosion_level(cave, coord)
        :ets.insert(cache, {{:erosion_level, coord}, level})
        level
    end
  end

  defp calc_erosion_level(cave = %Cave{depth: depth}, coord) do
    cave
    |> geo_index(coord)
    |> Kernel.+(depth)
    |> rem(20183)
  end

  def region_type(cave = %Cave{}, coord) do
    case cave |> erosion_level(coord) |> rem(3) do
      0 -> :rocky
      1 -> :wet
      2 -> :narrow
    end
  end

  # part2
  def fewest_minutes(cave = %Cave{target: target}) do
    shortest = dijkstra_search(cave, {{0, 0}, :torch})

    min(shortest[{target, :torch}], shortest[{target, :climbing_gear}] + 7)
  end

  def dijkstra_search(cave = %Cave{}, start) do
    connected_path_nodes = find_connected_path_nodes(cave, start)

    dijkstra_search(cave, %{start => 0}, %{}, connected_path_nodes)
  end

  defp dijkstra_search(cave = %Cave{}, dist, shortest, connected_path_nodes) do
    case dist
         |> Stream.reject(fn {path_node, cost} -> shortest[path_node] end)
         |> Enum.min_by(fn {_path_node, cost} -> cost end, fn -> :none end) do
      :none -> shortest
      {current_path_node, current_cost} ->
        new_shortest = Map.put(shortest, current_path_node, current_cost)
        new_dist =
          connected_path_nodes[current_path_node]
          |> Stream.reject(fn {path_node, _} -> shortest[path_node] end)
          |> Enum.reduce(dist, fn {path_node, cost}, new_dist ->
            new_cost = current_cost + cost
            case new_dist[path_node] do
              cost when not is_nil(cost) and cost <= new_cost ->  new_dist
              _ -> Map.put(new_dist, path_node, new_cost)
            end
          end)
        dijkstra_search(cave, new_dist, new_shortest, connected_path_nodes)
    end
  end

  # Using BFS to find all connected path_nodes and the cost
  def find_connected_path_nodes(cave = %Cave{}, start) do
    find_connected_path_nodes(cave, %{}, :queue.from_list([start]))
  end
  defp find_connected_path_nodes(%Cave{}, result, _unchecked = {[], []}), do: result
  defp find_connected_path_nodes(cave = %Cave{}, result, unchecked) do
    {{:value, path_node = {_coord, tool}}, rest_unchecked} = :queue.out(unchecked)
    case result[path_node] do
      nil ->
        neighbors = valid_choices(cave, path_node)

        neighbors_cost =
          neighbors
          |> Stream.map(fn {_, t} = p -> {p, 1 + switch_tool_cost(tool, t)} end)
          |> Enum.into(%{})

        result = Map.put(result, path_node, neighbors_cost)
        unchecked = :queue.join(rest_unchecked, :queue.from_list(neighbors))

        find_connected_path_nodes(cave, result, unchecked)
      _ -> find_connected_path_nodes(cave, result, rest_unchecked)
    end
  end

  def valid_choices(cave = %Cave{}, {current_coord, _current_tool}) do
    valid_tools = suitable_tools(cave, current_coord)
    max_x = max_x(cave)
    max_y = max_y(cave)

    current_coord
    |> adjacent_coords()
    |> Stream.map(fn coord ->
      {coord, suitable_tools(cave, coord) |> Enum.filter(&(&1 in valid_tools))}
    end)
    |> Stream.reject(fn {{x, y}, tools} -> x > max_x or y > max_y or tools == [] end)
    |> Enum.flat_map(fn {coord, tools} -> Enum.map(tools, &{coord, &1}) end)
  end


  # TODO need to figure out the smallest max_x and max_y
  defp max_x(%Cave{target: {x, _}}), do: x + 14
  defp max_y(%Cave{target: {_, y}}), do: y + 14

  defp adjacent_coords({x, y}) do
    for {i, j} <- [{x - 1, y}, {x, y + 1}, {x + 1, y}, {x, y - 1}], i >= 0, j >= 0, do: {i, j}
  end

  defp suitable_tools(cave = %Cave{}, coord) do
    case region_type(cave, coord) do
      :rocky -> [:climbing_gear, :torch]
      :wet -> [:climbing_gear, nil]
      :narrow -> [:torch, nil]
    end
  end

  defp switch_tool_cost(tool, tool), do: 0
  defp switch_tool_cost(_, _new_tool), do: 7
end

defmodule Day22 do
  def part1(depth, target) do
    Cave.new(depth, target) |> Cave.total_risk_level()
  end

  def part2(depth, target) do
    Cave.new(depth, target) |> Cave.fewest_minutes()
  end

  def parse_input(input) do
    ["depth: " <> depth, "target: " <> target] = String.split(input, "\n", trim: true)

    {String.to_integer(depth),
     target |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()}
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day22Test do
      use ExUnit.Case

      test "part 1 result" do
        assert Day22.part1(510, {10, 10}) == 114
      end

      test "part 2 result" do
        assert Day22.part2(510, {10, 10}) == 45
      end
    end

  [input, "--part1"] ->
    {depth, target} = Day22.parse_input(input |> File.read!())

    Day22.part1(depth, target)
    |> IO.inspect()

  [input, "--part2"] ->
    {depth, target} = Day22.parse_input(input |> File.read!())

    Day22.part2(depth, target)
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input] [--flag]")
end
