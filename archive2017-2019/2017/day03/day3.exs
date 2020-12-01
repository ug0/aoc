defmodule Day3 do
  def part1(1), do: 0
  def part1(num) when num > 1 do
    squares = [{2, {1, 0}}, {1, {0, 0}}]
    taken = %{{0, 0} => 1, {1, 0} => 2}

    [{_, pos} | _] = take_steps_while(3, {1, 0}, {0, 1}, squares, taken, fn
      n, _pos, squares, _ when n > num -> {:halt, squares}
      n, _, _, _ -> {:cont, n}
    end)

    manhattan_distance({0, 0}, pos)
  end

  def part2(num) do
    squares = [{1, {1, 0}}, {1, {0, 0}}]
    taken = %{{0, 0} => 1, {1, 0} => 1}

    calc_value = fn pos, taken ->
      for(i <- [-1, 0, 1], j <- [-1, 0, 1], i != 0 or j != 0, do: taken[make_move(pos, {i, j})])
      |> Stream.filter(& &1 != nil)
      |> Enum.sum()
    end

    take_steps_while(3, {1, 0}, {0, 1}, squares, taken, fn _n, pos, _squares, taken ->
      case calc_value.(pos, taken) do
        value when value > num -> {:halt, value}
        value -> {:cont, value}
      end
    end)
  end

  defp manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp take_steps_while(n, current, move, squares, taken, func) do
    next = make_move(current, new_move = turn_left(move))
    {next, new_move} = case(taken) do
      %{^next => _} -> {make_move(current, move), move}
      _ -> {next, new_move}
    end

    case func.(n, next, squares, taken) do
      {:cont, value} -> take_steps_while(n + 1, next, new_move, [{value, next} | squares], Map.put(taken, next, value), func)
      {:halt, result} -> result
    end
  end

  ## Only solve part1
  # defp take_steps(m, n, _current, _move, squares, _taken) when m > n do
  #   squares
  # end

  # defp take_steps(m, n, current, move, squares, taken) do
  #   next = make_move(current, new_move = turn_left(move))

  #   if MapSet.member?(taken, next) do
  #     next = make_move(current, move)
  #     take_steps(m + 1, n, next, move, Map.put(squares, m, next), MapSet.put(taken, next))
  #   else
  #     take_steps(m + 1, n, next, new_move, Map.put(squares, m, next), MapSet.put(taken, next))
  #   end
  # end

  defp turn_left({1, 0}), do: {0, 1}
  defp turn_left({0, 1}), do: {-1, 0}
  defp turn_left({-1, 0}), do: {0, -1}
  defp turn_left({0, -1}), do: {1, 0}

  defp make_move({x, y}, {i, j}) do
    {x + i, y + j}
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day3Test do
      use ExUnit.Case

      test "part1 result" do
        assert Day3.part1(1) == 0
        assert Day3.part1(12) == 3
        assert Day3.part1(23) == 2
        assert Day3.part1(1024) == 31
      end

      test "part2 result" do
        assert Day3.part2(1) == 2
        assert Day3.part2(2) == 4
        assert Day3.part2(3) == 4
        assert Day3.part2(4) == 5
        assert Day3.part2(5) == 10
        assert Day3.part2(6) == 10
        assert Day3.part2(7) == 10
        assert Day3.part2(8) == 10
        assert Day3.part2(9) == 10
      end
    end

  [input, "--part1"] ->
    input
    |> String.to_integer()
    |> Day3.part1()
    |> IO.puts()

  [input, "--part2"] ->
    input
    |> String.to_integer()
    |> Day3.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
