defmodule Aoc.Y2021.D17 do
  use Aoc.Input

  defmodule Area do
    defstruct [:x_range, :y_range]

    def new(x_range, y_range) do
      %__MODULE__{x_range: x_range, y_range: y_range}
    end

    def in_area?(%__MODULE__{} = area, {x, y}) do
      x in area.x_range and y in area.y_range
    end
  end

  defmodule Probe do
    alias Aoc.Y2021.D17.Area

    defstruct [:trace, :velocity]
    @start {0, 0}
    def new(initial_velocity, start \\ @start) do
      %__MODULE__{velocity: initial_velocity, trace: [start]}
    end

    def try_reaching_area(%Probe{} = probe, %Area{} = area) do
      case state(probe, area) do
        :inside -> {:reached, probe}
        :away -> {:away, probe}
        :reaching -> probe |> next() |> try_reaching_area(area)
      end
    end

    def current_pos(%__MODULE__{trace: [current | _]}) do
      current
    end

    def next(%__MODULE__{trace: [{x, y} | _] = trace, velocity: {vx, vy}}) do
      %__MODULE__{trace: [{x + vx, y + vy} | trace], velocity: {reduce_vx(vx), vy - 1}}
    end

    defp state(%__MODULE__{} = probe, %Area{x_range: x_range, y_range: y_range} = area) do
      {x, y} = pos = current_pos(probe)

      cond do
        Area.in_area?(area, pos) -> :inside
        x > x_range.last or y < y_range.first -> :away
        true -> :reaching
      end
    end

    defp reduce_vx(0), do: 0
    defp reduce_vx(n), do: n - 1
  end

  alias __MODULE__.{Probe, Area}

  def part1(str \\ nil) do
    (str || input())
    |> parse_area()
    |> find_all_probes_can_reach_area()
    |> Stream.map(fn probe ->
      probe.trace |> Stream.map(&elem(&1, 1)) |> Enum.max()
    end)
    |> Enum.max()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> parse_area()
    |> find_all_probes_can_reach_area()
    |> Enum.count()
    |> IO.inspect()
  end

  defp find_all_probes_can_reach_area(%Area{} = area) do
    max_vx = area.x_range.last
    max_vy = -area.y_range.first

    # can use smaller `vy` range for part1
    for(vx <- 0..max_vx, vy <- area.y_range.first..max_vy, do: {vx, vy})
    |> Stream.map(&Probe.new(&1))
    |> Stream.map(&Probe.try_reaching_area(&1, area))
    |> Stream.filter(fn {state, _} -> state == :reached end)
    |> Enum.map(fn {_, probe} -> probe end)
  end

  defp parse_area(str) do
    [_, _, "x=" <> x_range, "y=" <> y_range] = String.split(str)

    [min_x, max_x] =
      x_range
      |> String.trim_trailing(",")
      |> String.splitter("..")
      |> Enum.map(&String.to_integer/1)

    [min_y, max_y] = y_range |> String.splitter("..") |> Enum.map(&String.to_integer/1)

    Area.new(min_x..max_x, min_y..max_y)
  end
end
