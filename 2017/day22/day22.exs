defmodule Day22 do
  alias __MODULE__.{Grid, Virus, Printer}

  def part1(input, bursts \\ 10000) do
    infect_grid(input, bursts, :v1)
  end

  def part2(input, bursts \\ 10_000_000) do
    infect_grid(input, bursts, :v2)
  end

  defp infect_grid(input, bursts, version) do
    grid = Grid.parse(input)
    virus = grid |> Grid.center() |> Virus.new()

    1..bursts
    |> Enum.reduce({grid, virus, 0}, fn _, {grid, virus, infection_bursts} ->
      case update_grid_node(grid, virus.coord, version) do
        {new_grid, ?#} -> {new_grid, virus_act(virus, grid), infection_bursts + 1}
        {new_grid, _} -> {new_grid, virus_act(virus, grid), infection_bursts}
      end
    end)
    |> elem(2)
  end

  def update_grid_node(grid, coord, :v1) do
    case Grid.get_node(grid, coord) do
      ?. -> {Grid.put_node(grid, coord, ?#), ?#}
      ?# -> {Grid.put_node(grid, coord, ?.), ?.}
    end
  end

  def update_grid_node(grid, coord, :v2) do
    case Grid.get_node(grid, coord) do
      ?. -> {Grid.put_node(grid, coord, ?W), ?W}
      ?W -> {Grid.put_node(grid, coord, ?#), ?#}
      ?# -> {Grid.put_node(grid, coord, ?F), ?F}
      ?F -> {Grid.put_node(grid, coord, ?.), ?.}
    end
  end

  defp virus_act(virus, grid) do
    case Grid.get_node(grid, virus.coord) do
      ?. -> Virus.turn_left(virus)
      ?# -> Virus.turn_right(virus)
      ?W -> virus
      ?F -> Virus.turn_back(virus)
    end
    |> Virus.move()
  end

  defmodule Grid do
    @moduledoc """
    0 ------> y
    .
    .
    .
    x
    """

    def parse(raw_input) do
      raw_input
      |> String.split("\n", trim: true)
      |> Stream.map(&to_charlist/1)
      |> Stream.map(&Enum.with_index/1)
      |> Stream.with_index()
      |> Stream.flat_map(fn {cols, x} ->
        Enum.map(cols, fn {node, y} -> {{x, y}, node} end)
      end)
      |> Enum.into(%{})
    end

    def get_node(grid, coord) do
      Map.get(grid, coord, ?.)
    end

    def put_node(grid, coord, node) do
      Map.put(grid, coord, node)
    end

    def center(grid) do
      coords = Map.keys(grid)
      {{min_x, _}, {max_x, _}} = Enum.min_max_by(coords, fn {x, _} -> x end)
      {{_, min_y}, {_, max_y}} = Enum.min_max_by(coords, fn {_, y} -> y end)

      {div(min_x + max_x, 2), div(min_y + max_y, 2)}
    end
  end

  defmodule Virus do
    defstruct [:coord, :direction]

    def new(coord) do
      %__MODULE__{coord: coord, direction: {-1, 0}}
    end

    def move(%__MODULE__{coord: {x, y}, direction: {i, j}}) do
      %__MODULE__{coord: {x + i, y + j}, direction: {i, j}}
    end

    def turn_left(%__MODULE__{direction: {x, y}} = virus) do
      %__MODULE__{virus | direction: {-y, x}}
    end

    def turn_right(%__MODULE__{direction: {x, y}} = virus) do
      %__MODULE__{virus | direction: {y, -x}}
    end

    def turn_back(%__MODULE__{direction: {x, y}} = virus) do
      %__MODULE__{virus | direction: {-x, -y}}
    end
  end

  defmodule Printer do
    @moduledoc """
    For debugging and fun
    """

    def display(grid, virus) do
      coords = Map.keys(grid)
      {{min_x, _}, {max_x, _}} = Enum.min_max_by(coords, fn {x, _} -> x end)
      {{_, min_y}, {_, max_y}} = Enum.min_max_by(coords, fn {_, y} -> y end)

      min_x..max_x
      |> Stream.map(fn x ->
        min_y..max_y
        |> Enum.map(fn y ->
          node = Grid.get_node(grid, {x, y})

          case virus do
            %{coord: {^x, ^y}} -> [?[, node, ?]]
            _ -> [?\s, node, ?\s]
          end
        end)
        |> to_string()
      end)
      |> Enum.join("\n")
      |> IO.puts()
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day22Test do
      use ExUnit.Case

      @input """
      ..#
      #..
      ...
      """
      test "part1" do
        assert Day22.part1(@input, 7) == 5
        assert Day22.part1(@input, 70) == 41
        assert Day22.part1(@input, 10000) == 5587
      end

      test "part2" do
        assert Day22.part2(@input, 100) == 26
        assert Day22.part2(@input, 10_000_000) == 2511944
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day22.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day22.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
