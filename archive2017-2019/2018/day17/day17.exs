defmodule Ground do
  def build(lines) do
    ground = :ets.new(__MODULE__, [:set, :protected])

    Enum.each(lines, fn line ->
      line
      |> parse_line()
      |> Enum.each(fn coord ->
        :ets.insert(ground, {coord, :clay})
      end)
    end)

    ground
  end

  def watered_areas(ground) do
    min_y = :ets.select(ground, [{{{:"$1", :"$2"}, :clay}, [], [:"$2"]}]) |> Enum.min()
    :ets.select_count(ground, [
      {{{:"$1", :"$2"}, :"$3"}, [{:>=, :"$2", min_y}],
       [{:orelse, {:"=:=", :"$3", :fall}, {:"=:=", :"$3", :water}}]}
    ])
  end

  def final_watered_areas(ground) do
    min_y = :ets.select(ground, [{{{:"$1", :"$2"}, :clay}, [], [:"$2"]}]) |> Enum.min()
    :ets.select_count(ground, [{{{:"$1", :"$2"}, :water}, [], [{:>, :"$2", min_y}]}])
  end

  def falling(ground, _spring_coord = {x, y}) do
    case get_coord_info(ground, {x, y + 1}) do
      :fall -> nil
      info when info in [:clay, :water] -> spread(ground, {x, y})
      :sand -> falling_down(ground, {x, y + 1})
    end
  end

  defp spread(ground, {x, y}) do
    case {spread_left(ground, {x, y}), spread_right(ground, {x, y})} do
      {{:end_clay, {left, _}}, {:end_clay, {right, _}}} ->
        fill(ground, left..right, y, :water)
        spread(ground, {x, y - 1})
      {{end_left, {left, _}}, {end_right, {right, _}}} ->
        fill(ground, left..right, y, :fall)
        end_left == :end_fall and falling(ground, {left, y})
        end_right == :end_fall and falling(ground, {right, y})
    end
  end
  defp spread_left(ground, coord), do: spread_side(ground, coord, &(&1 - 1))
  defp spread_right(ground, coord), do: spread_side(ground, coord, &(&1 + 1))
  defp spread_side(ground, {x, y}, next_x_fun) when is_function(next_x_fun) do
    next_x = next_x_fun.(x)
    case {get_coord_info(ground, {next_x, y}), get_coord_info(ground, {next_x, y + 1})} do
      {:clay, _} -> {:end_clay, {x, y}}
      {_, down} when down in [:clay, :water] -> spread_side(ground, {next_x, y}, next_x_fun)
      {_, _} -> {:end_fall, {next_x, y}}
    end
  end

  defp falling_down(ground, coord) do
    if reach_the_bottom?(ground, coord) do
      :done
    else
      fill(ground, coord, :fall)
      falling(ground, coord)
    end
  end

  defp reach_the_bottom?(ground, {_x, y}) do
    :ets.select_count(ground, [{{{:_, :"$1"}, :clay}, [], [{:>=, :"$1", y}]}]) == 0
  end

  defp fill(ground, coord, info) do
    :ets.insert(ground, {coord, info})
  end
  defp fill(ground, left..right, y, info) do
    Enum.each(left..right, fn x ->
      fill(ground, {x, y}, info)
    end)
  end

  # for fun and debugging
  def display(ground, spring_coord \\ nil) do
    coords = get_all_coords(ground)
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(coords, fn {x, _} -> x end)
    {_, max_y} = Enum.max_by(coords, fn {_, y} -> y end)

    0..max_y
    |> Enum.each(fn y ->
      min_x..max_x
      |> Enum.map(fn x ->
        cond do
          {x, y} == spring_coord -> ?+
          get_coord_info(ground, {x, y}) == :clay -> ?#
          get_coord_info(ground, {x, y}) == :water -> ?~
          get_coord_info(ground, {x, y}) == :fall -> ?|
          true -> ?.
        end
      end)
      |> IO.puts()
    end)

    IO.puts("\n")
  end

  defp get_coord_info(ground, coord) do
    case :ets.lookup(ground, coord) do
      [{_, info}] -> info
      [] -> :sand
    end
  end

  defp get_all_coords(ground) do
    :ets.select(ground, [{{:"$1", :_}, [], [:"$1"]}])
  end

  defp parse_line(line) do
    %{"x" => range_x, "y" => range_y} =
      line
      |> String.splitter(", ")
      |> Stream.map(&String.split(&1, "="))
      |> Enum.reduce(%{}, fn [x_or_y, num_or_range], acc ->
        case String.split(num_or_range, ~r/[^0-9]/, trim: true) do
          [num] ->
            num = String.to_integer(num)
            Map.put_new(acc, x_or_y, num..num)

          [min, max] ->
            min = String.to_integer(min)
            max = String.to_integer(max)
            Map.put_new(acc, x_or_y, min..max)
        end
      end)

    for x <- range_x, y <- range_y, do: {x, y}
  end
end

defmodule Day17 do
  def part1(input) do
    ground =
      input
      |> String.split("\n", trim: true)
      |> Ground.build()

    Ground.falling(ground, {500, 0})

    # Ground.display(ground, {500, 0})
    Ground.watered_areas(ground)
  end

  def part2(input) do
    ground =
      input
      |> String.split("\n", trim: true)
      |> Ground.build()

    Ground.falling(ground, {500, 0})
    Ground.final_watered_areas(ground)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day17Test do
      use ExUnit.Case

      @input """
      x=495, y=2..7
      y=7, x=495..501
      x=501, y=3..7
      x=498, y=2..4
      x=506, y=1..2
      x=498, y=10..13
      x=504, y=10..13
      y=13, x=498..504
      """
      test "part 1 result" do
        assert 57 == Day17.part1(@input)
      end

      test "part 2 result" do
        assert 29 == Day17.part2(@input)
      end
    end

  [input, "--part1"] ->
    input
    |> File.read!()
    |> Day17.part1()
    |> IO.inspect()

  [input, "--part2"] ->
    input
    |> File.read!()
    |> Day17.part2()
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input_file]")
end
