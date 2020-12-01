defmodule Day11 do
  @moduledoc """
  https://en.wikipedia.org/wiki/Summed-area_table
  """

  @size 300

  def part1(serial_number) do
    cells = cells_with_power(serial_number)
    summed_table = SummedAreaTable.create(300, &Map.fetch!(cells, {&1, &2}))

    for x <- 1..(@size - 2), y <- 1..(@size - 2) do
      {{x, y}, {x + 2, y + 2}}
    end
    |> Enum.max_by(fn {top_left, bottom_right} -> SummedAreaTable.sum(summed_table, top_left, bottom_right) end)
  end

  def part2(serial_number) do
    cells = cells_with_power(serial_number)
    summed_table = SummedAreaTable.create(@size, &Map.fetch!(cells, {&1, &2}))

    for x <- 1..@size, y <- 1..@size do
      {x, y}
    end
    |> Stream.flat_map(fn {x, y} ->
      for i <- 0..(@size - max(x, y)) do
        {{x, y}, {x + i, y + i}}
      end
    end)
    |> Enum.max_by(fn {top_left, bottom_right} -> SummedAreaTable.sum(summed_table, top_left, bottom_right) end)
  end

  def cells_with_power(serial_number) do
    for x <- 1..300, y <- 1..300, into: %{} do
      {{x, y}, power_of_cell({x, y}, serial_number)}
    end
  end

  defp power_of_cell({x, y}, serial_number) do
    rack_id = x + 10

    y
    |> Kernel.*(rack_id)
    |> Kernel.+(serial_number)
    |> Kernel.*(rack_id)
    |> rem(1000)
    |> div(100)
    |> Kernel.-(5)
  end
end

defmodule SummedAreaTable do
  def create(1, point_value) do
    %{{1, 1} => point_value.(1, 1)}
  end

  def create(size, point_value) do
    scale(create(size - 1, point_value), size, point_value)
  end

  @doc """
  scale N-size summed-table to N+1
  """
  defp scale(table, next_size, point_value) do
    new_table =
      Stream.unfold({0, 0, 1}, fn
        {_, _, ^next_size} ->
          nil

        {sum_next_x, sum_next_y, i} ->
          new_sum_next_x = sum_next_x + point_value.(i, next_size)
          new_sum_next_y = sum_next_y + point_value.(next_size, i)

          {{new_sum_next_x, new_sum_next_y, i}, {new_sum_next_x, new_sum_next_y, i + 1}}
      end)
      |> Enum.reduce(table, fn {sum_x, sum_y, i}, acc ->
        acc
        |> Map.put({i, next_size}, sum_x + sum(acc, {i, next_size - 1}))
        |> Map.put({next_size, i}, sum_y + sum(acc, {next_size - 1, i}))
      end)

    new_table
    |> Map.put(
      {next_size, next_size},
      sum(new_table, {next_size - 1, next_size}) + sum(new_table, {next_size, next_size - 1}) +
        point_value.(next_size, next_size) - sum(new_table, {next_size - 1, next_size - 1})
    )
  end

  def sum(_table, {_, 0}), do: 0
  def sum(_table, {0, _}), do: 0
  def sum(table, top_left), do: Map.fetch!(table, top_left)

  def sum(table, _top_left = {x0, y0}, bottom_right = {x1, y1}) do
    sum(table, bottom_right) - sum(table, {x1, y0 - 1}) - sum(table, {x0 - 1, y1}) + sum(table, {x0 - 1, y0 - 1})
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day11Test do
      use ExUnit.Case

      test "part 1 result" do
        assert {{33, 45}, {35, 47}} == Day11.part1(18) # sum: 29
        assert {{21, 61}, {23, 63}} == Day11.part1(42) # sum: 30
      end

      test "part 2 result" do
        assert {{90, 269}, {105, 284}} == Day11.part2(18) # sum: 113
        assert {{232, 251}, {243, 262}} == Day11.part2(42) # sum: 30
      end
    end

  [input, "--part1"] ->
    input
    |> String.to_integer()
    |> Day11.part1()
    |> IO.inspect()
  [input, "--part2"] ->
    input
    |> String.to_integer()
    |> Day11.part2()
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input_file]")
end
