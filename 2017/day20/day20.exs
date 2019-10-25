defmodule Day20 do
  alias __MODULE__.Particle

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&Particle.from_raw_input/1)
    |> Stream.iterate(fn i ->
      Enum.map(i, &Particle.update/1)
    end)
    |> Enum.each(fn i ->
      i
      |> Stream.with_index()
      |> Enum.min_by(fn {p, _i} -> Particle.distance_to_zero(p) end)
      |> elem(1)
      # answer appears when the output becomes stable
      |> IO.inspect()
    end)
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&Particle.from_raw_input/1)
    |> Stream.iterate(fn i ->
      i
      |> Enum.group_by(fn p -> p.p end)
      |> Stream.filter(fn {_, group} -> length(group) == 1 end)
      |> Stream.map(fn {_, [p]} -> p end)
      |> Enum.map(&Particle.update/1)
    end)
    |> Enum.each(fn i ->
      # answer appears when the output becomes stable
      i |> length() |> IO.inspect()
    end)
  end

  defmodule Particle do
    defstruct [:p, :v, :a]

    def from_raw_input(str) do
      str
      |> String.splitter(", ")
      |> Stream.map(&String.split(&1, "="))
      |> Enum.into(%{}, fn
        ["p", coords] -> {:p, parse_coords(coords)}
        ["v", coords] -> {:v, parse_coords(coords)}
        ["a", coords] -> {:a, parse_coords(coords)}
      end)
      |> (&struct(__MODULE__, &1)).()
    end

    defp parse_coords(str) do
      str
      |> String.replace(["<", ">"], "")
      |> String.splitter(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end

    def distance_to_zero(%__MODULE__{p: {x, y, z}}) do
      abs(x) + abs(y) + abs(z)
    end

    def update(%__MODULE__{} = p) do
      p
      |> update_v()
      |> update_p()
    end

    def update_p(%__MODULE__{p: {px, py, pz}, v: {vx, vy, vz}} = p) do
      %{p | p: {px + vx, py + vy, pz + vz}}
    end

    def update_v(%__MODULE__{a: {ax, ay, az}, v: {vx, vy, vz}} = p) do
      %{p | v: {vx + ax, vy + ay, vz + az}}
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day20Test do
      use ExUnit.Case

      test "part1 result" do
      end

      test "part2 result" do
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day20.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day20.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
