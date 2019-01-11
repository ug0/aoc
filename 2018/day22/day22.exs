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

  def geo_index(cave, {x, y}),
    do: erosion_level(cave, {x - 1, y}) * erosion_level(cave, {x, y - 1})

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
  def fewest_minutes(cave = %Cave{}) do
    start = {{0, 0}, :torch}
    graph = build_graph(cave)

    {costs, priority_q} = graph
    |> :digraph.vertices()
    |> Stream.reject(& &1 == start)
    |> Enum.reduce({%{start => 0}, _priority_q = %{start => 0}}, fn v, {costs, priority_q} ->
      {Map.put(costs, v, :infinity), Map.put(priority_q, v, :infinity)}
    end)

    find_fewest_cost_to_target(cave, graph, costs, priority_q)
  end

  defp find_fewest_cost_to_target(cave = %Cave{target: target}, graph, costs, priority_q) do
    cond do
      !Map.has_key?(priority_q, {target, :torch}) and !Map.has_key?(priority_q, {target, :climbing_gear}) ->
        {candidate1, candidate2} = {{target, :torch}, {target, :climbing_gear}}
        %{^candidate1 => cost1, ^candidate2 => cost2} = costs
        min(cost1, cost2 + switch_tool_cost(:climbing_gear, :torch))

      true ->
        dijkstra_search(cave, graph, costs, priority_q)
    end
  end

  defp dijkstra_search(cave = %Cave{}, graph, costs, priority_q) do
    {current, _} = Enum.min_by(priority_q, fn {_, cost} -> cost end)
    priority_q = Map.delete(priority_q, current)

    {costs, priority_q} =
      graph
      |> :digraph.out_edges(current)
      |> Stream.map(&:digraph.edge(graph, &1))
      |> Stream.filter(fn {_, _, neighbor, _} -> Map.has_key?(priority_q, neighbor) end)
      |> Enum.reduce({costs, priority_q}, fn {_e, ^current, neighbor, cost}, {costs, priority_q} ->
        new_cost = costs[current] + cost

        if costs[neighbor] > new_cost do
          {Map.put(costs, neighbor, new_cost), %{priority_q | neighbor => new_cost}}
        else
          {costs, priority_q}
        end
      end)

    find_fewest_cost_to_target(cave, graph, costs, priority_q)
  end

  def build_graph(cave = %Cave{}) do
    build_graph(cave, :digraph.new(), MapSet.new(), :queue.from_list([{{0, 0}, :torch}]))
  end

  defp build_graph(%Cave{}, graph, _checked, _unchecked = {[], []}), do: graph

  defp build_graph(cave = %Cave{}, graph, checked, unchecked) do
    {{:value, current = {_coord, tool}}, rest_unchecked} = :queue.out(unchecked)

    if MapSet.member?(checked, current) do
      build_graph(cave, graph, checked, rest_unchecked)
    else
      _add_current_vertex = :digraph.add_vertex(graph, current)
      neighbors = cave |> valid_choices(current)

      _add_edges_to_neighbors =
        neighbors
        |> Enum.each(fn neighbor = {_, neighbor_tool} ->
          _add_neighbor_vertex = :digraph.add_vertex(graph, neighbor)
          :digraph.add_edge(graph, current, neighbor, 1 + switch_tool_cost(tool, neighbor_tool))
        end)

      unchecked = :queue.join(rest_unchecked, :queue.from_list(neighbors))
      build_graph(cave, graph, MapSet.put(checked, current), unchecked)
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
