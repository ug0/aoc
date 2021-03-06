defmodule AreaState do
  @open_acre ?.
  @trees ?|
  @lumberyard ?#

  def build(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {line, y}, state ->
      line
      |> to_charlist()
      |> Stream.with_index()
      |> Enum.reduce(state, fn {symbol, x}, state ->
        Map.put(state, {x, y}, symbol)
      end)
    end)
  end

  def resource_value(state) do
    %{@trees => wooded_acres, @lumberyard => lumberyards} =
      Enum.group_by(state, fn {_, symbol} -> symbol end)

    length(wooded_acres) * length(lumberyards)
  end

  def hash(state) do
    str =
      state
      |> Enum.sort_by(fn {coord, _} -> coord end)
      |> Stream.map(fn {_, symbol} -> symbol end)
      |> Enum.join("")

    :crypto.hash(:sha256, str) |> Base.encode16()
  end

  def iterate(state, 0), do: state

  def iterate(state, n) do
    state
    |> Enum.reduce(state, fn {coord, _symbol}, new_state ->
      %{new_state | coord => transform(state, coord)}
    end)
    |> iterate(n - 1)
  end

  defp transform(state, coord = {_, _}) do
    transform(state[coord], adjacent_symbols(state, coord))
  end

  defp transform(@open_acre, adjacents) when is_list(adjacents) do
    if Enum.count(adjacents, &(&1 == @trees)) > 2 do
      @trees
    else
      @open_acre
    end
  end

  defp transform(@trees, adjacents) when is_list(adjacents) do
    if Enum.count(adjacents, &(&1 == @lumberyard)) > 2 do
      @lumberyard
    else
      @trees
    end
  end

  defp transform(@lumberyard, adjacents) when is_list(adjacents) do
    if Enum.any?(adjacents, &(&1 == @lumberyard)) and Enum.any?(adjacents, &(&1 == @trees)) do
      @lumberyard
    else
      @open_acre
    end
  end

  defp adjacent_symbols(state, coord) do
    coord
    |> adjacent_coords()
    |> Stream.map(&state[&1])
    |> Enum.filter(& &1)
  end

  defp adjacent_coords({x, y}) do
    [
      {x, y - 1},
      {x + 1, y - 1},
      {x + 1, y},
      {x + 1, y + 1},
      {x, y + 1},
      {x - 1, y + 1},
      {x - 1, y},
      {x - 1, y - 1}
    ]
  end

  # for fun and debugging
  def display(state, size) do
    0..(size - 1)
    |> Enum.each(fn y ->
      0..(size - 1)
      |> Enum.map(&state[{&1, y}])
      |> IO.puts()
    end)

    IO.puts("\n")
  end
end

defmodule Day18 do
  def part1(input) do
    input
    |> AreaState.build()
    |> AreaState.iterate(10)
    |> AreaState.resource_value()
  end

  def part2(input) do
    state = input |> AreaState.build()

    total = 1_000_000_000

    1..total
    |> Enum.reduce_while({state, %{}}, fn i, {new_state, result} ->
      new_state = AreaState.iterate(new_state, 1)
      hash = AreaState.hash(new_state)
      resource_value = AreaState.resource_value(new_state)

      case result[hash] do
        nil ->
          {:cont, {new_state, Map.put(result, hash, {i, resource_value})}}

        {cycle_start, _} ->
          repeated_iterate = rem(total - cycle_start, i - cycle_start) + cycle_start

          {_, {_, final_value}} =
            Enum.find(result, fn {_, {iterate, _}} -> iterate == repeated_iterate end)

          {:halt, final_value}
      end
    end)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day18Test do
      use ExUnit.Case

      @input """
      .#.#...|#.
      .....#|##|
      .|..|...#.
      ..|#.....#
      #.#|||#|#|
      ...#.||...
      .|....|...
      ||...#|.#|
      |.||||..|.
      ...#.|..|.
      """
      test "part 1 result" do
        assert 1147 == Day18.part1(@input)
      end
    end

  [input, "--part1"] ->
    input
    |> File.read!()
    |> Day18.part1()
    |> IO.inspect()

  [input, "--part2"] ->
    input
    |> File.read!()
    |> Day18.part2()
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input_file]")
end
