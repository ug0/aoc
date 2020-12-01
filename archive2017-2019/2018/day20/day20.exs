defmodule RouteMap do
  def traverse_routes(routes) do
    traverse_routes(routes, _init_map = %{{0, 0} => 0}, _current_location = {_pos = {0, 0}, _doors = 0}, _saved_locations = [])
  end

  def traverse_routes("^" <> rest, map, current_location, saved_locations),
    do: traverse_routes(rest, map, current_location, saved_locations)

  def traverse_routes("$", map, _, _), do: map
  def traverse_routes("(" <> rest, map, current_location, saved_locations) do
    traverse_routes(rest, map, current_location, [current_location | saved_locations])
  end

  def traverse_routes("|)" <> rest, map, _current_location, [last_saved_location | rest_saved_locations]) do
    traverse_routes(rest, map, last_saved_location, rest_saved_locations)
  end

  def traverse_routes(")" <> rest, map, _current_location, [last_saved_location | rest_saved_locations]) do
    traverse_routes(rest, map, last_saved_location, rest_saved_locations)
  end

  def traverse_routes("|" <> rest, map, _current_location, saved_locations = [last_saved_location | _]) do
    traverse_routes(rest, map, last_saved_location, saved_locations)
  end

  def traverse_routes(<<next_route::size(8), rest::binary>>, map, {pos, doors}, saved_locations) do
    room_pos = room_pos_after_route(next_route, pos)
    new_map = update_room(map, room_pos, doors + 1)
    traverse_routes(rest, new_map, {room_pos, doors + 1}, saved_locations)
  end

  defp update_room(map, room_pos, doors) do
    Map.update(map, room_pos, doors, fn old_doors -> min(doors, old_doors) end)
  end

  defp room_pos_after_route(route, pos_before_door), do: pos_after_route(route, pos_before_door, 2)

  defp pos_after_route(route, {x, y}, steps \\ 1) do
    case route do
      ?W -> {x - steps, y}
      ?N -> {x, y - steps}
      ?E -> {x + steps, y}
      ?S -> {x, y + steps}
    end
  end
end

defmodule Day20 do
  # the stacked-solution might not be the correct one for all general cases,
  # see the discussion here: https://www.reddit.com/r/adventofcode/comments/a7w4dj/2018_day_20_why_does_this_work/
  def part1(routes) do
    map = RouteMap.traverse_routes(routes)
    Enum.max(for {_, doors} <- map, do: doors)
  end

  def part2(routes) do
    map = RouteMap.traverse_routes(routes)
    Enum.count(for {_, doors} when doors >= 1000 <- map, do: doors)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day20Test do
      use ExUnit.Case

      test "part 1 result" do
        assert 3 == Day20.part1("^WNE$")
        assert 10 == Day20.part1("^ENWWW(NEEE|SSE(EE|N))$")
        assert 18 == Day20.part1("^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$")
        assert 23 == Day20.part1("^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$")
        assert 31 == Day20.part1("^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$")
      end
    end

  [input, "--part1"] ->
    input
    |> File.read!()
    |> Day20.part1()
    |> IO.inspect()

  [input, "--part2"] ->
    input
    |> File.read!()
    |> Day20.part2()
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input_file]")
end
