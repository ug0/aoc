defmodule Day19 do
  alias __MODULE__.RoutingDiagram

  def part1(input) do
    input
    |> RoutingDiagram.parse_diagram()
    |> traverse([], fn {point_type, _cursor}, path ->
      if point_type in ?A..?Z do
        [point_type | path]
      else
        path
      end
    end)
    |> Enum.reverse()
    |> to_string()
  end

  def part2(input) do
    input
    |> RoutingDiagram.parse_diagram()
    |> traverse(1, fn _, steps ->
      steps + 1
    end)
  end

  defp traverse(diagram, acc, fun) do
    traverse(diagram, RoutingDiagram.starting_point(diagram), acc, fun)
  end

  defp traverse(diagram, cursor, acc, fun) do
    # RoutingDiagram.display(diagram, cursor, range: 10, interval: 50)

    case RoutingDiagram.next(diagram, cursor) do
      nil ->
        acc

      {_, next_cursor} = step_result ->
        traverse(diagram, next_cursor, fun.(step_result, acc), fun)
    end
  end

  defmodule RoutingDiagram do
    def parse_diagram(input) do
      input
      |> String.splitter("\n", trim: true)
      |> Stream.map(&to_charlist/1)
      |> Stream.with_index()
      |> Stream.flat_map(fn {line, row} ->
        line
        |> Stream.with_index()
        |> Enum.map(fn {x, col} -> {{col, row}, x} end)
      end)
      |> Stream.filter(fn {_, x} -> x != ?\s end)
      |> Enum.into(%{})
    end

    def starting_point(diagram) do
      {pos, _} =
        Enum.find(diagram, fn
          {{_, 0}, ?|} -> true
          _ -> false
        end)

      {pos, {0, 1}}
    end

    def next(diagram, {pos, _} = cursor) do
      diagram
      |> possible_move_options(pos)
      |> Stream.map(&next_cursor(cursor, &1))
      |> Stream.map(fn {pos, _} = cur ->
        {Map.get(diagram, pos), cur}
      end)
      |> Enum.find(fn {point_type, _} -> reachable?(point_type) end)
    end

    defp possible_move_options(diagram, pos) do
      case Map.get(diagram, pos) do
        ?+ -> [:left, :right]
        _ -> [:forward]
      end
    end

    defp reachable?(?-), do: true
    defp reachable?(?|), do: true
    defp reachable?(?+), do: true
    defp reachable?(x) when x in ?A..?Z, do: true
    defp reachable?(_), do: false

    defp next_cursor({{x, y}, {i, j}}, :forward) do
      {{x + i, y + j}, {i, j}}
    end

    defp next_cursor(cursor, :left) do
      cursor
      |> cursor_turn_left()
      |> next_cursor(:forward)
    end

    defp next_cursor(cursor, :right) do
      cursor
      |> cursor_turn_right()
      |> next_cursor(:forward)
    end

    defp cursor_turn_left({pos, {i, j}}) do
      {pos, {j, -i}}
    end

    defp cursor_turn_right({pos, {i, j}}) do
      {pos, {-j, i}}
    end

    # for debugging and fun
    def display(diagram, cursor, opts \\ []) do
      case Keyword.fetch(opts, :interval) do
        {:ok, interval} when is_integer(interval) -> Process.sleep(interval)
        _ -> nil
      end

      IO.puts("\n")

      diagram
      |> represent(cursor, opts)
      |> IO.puts()

      IO.puts("\n")
    end

    def represent(diagram, {pos, _} = cursor, opts) do
      diagram = Map.put(diagram, pos, represent_cursor(cursor))
      {row_range, col_range} = represent_range(diagram, cursor, opts)

      Enum.map(row_range, fn row ->
        Enum.map(col_range, fn col ->
          Map.get(diagram, {col, row}, ?\s)
        end) ++ [?\n]
      end)
      |> to_string()
    end

    defp represent_range(diagram, {{col, row}, _}, opts) do
      case Keyword.fetch(opts, :range) do
        {:ok, range} when is_integer(range) ->
          {max(0, row - range)..(row + range), max(0, col - range * 2)..(col + range * 2)}

        _ ->
          {{max_col, _}, _} = Enum.max_by(diagram, fn {{i, _}, _} -> i end)
          {{_, max_row}, _} = Enum.max_by(diagram, fn {{_, j}, _} -> j end)
          {0..max_row, 0..max_col}
      end
    end

    defp represent_cursor({_, direction}) do
      case direction do
        {-1, 0} -> ?<
        {1, 0} -> ?>
        {0, 1} -> ?v
        {0, -1} -> ?^
      end
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day19Test do
      use ExUnit.Case

      @input """
          |
          |  +--+
          A  |  C
      F---|----E|--+
          |  |  |  D
          +B-+  +--+
      """
      test "part1 result" do
        assert Day19.part1(@input) == "ABCDEF"
      end

      test "part2 result" do
        assert Day19.part2(@input) == 38
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day19.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day19.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
