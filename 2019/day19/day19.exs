Code.load_file("../intcode_program.exs", __DIR__)

defmodule Day17 do
  alias IntcodeProgram, as: Program

  def part1(program) do
    for(i <- 0..49, j <- 0..49, do: {i, j})
    |> Stream.map(&scan_point(program, &1))
    |> Enum.count(fn v -> v == 1 end)
  end

  def part2(program) do
    # enable_grid_cache()

    ## print the grid to find a pattern.
    # size = 100
    # for(i <- 0..(size - 1), j <- 0..(size - 1), do: {i, j})
    # |> Stream.map(&{&1, scan_point(program, &1)})
    # |> Enum.into(%{})
    # |> display_grid(size)

    {x, y} = find_closest_square(program, 100, {100, 100})
    x * 10000 + y
  end

  defp find_closest_square(program, size, {x0, y0}) do
    x =
      x0
      |> Stream.iterate(&(&1 + 1))
      |> Enum.find(&(scan_point(program, {&1, y0}) == 1))

    find_closest_square(program, size, {x, y0}, x + 1)
  end

  defp find_closest_square(program, size, {x0, y0} = start, x) do
    cond do
      scan_point(program, {x, y0}) == 0 or scan_point(program, {x + size - 1, y0}) == 0 ->
        find_closest_square(program, size, {x0 + 1, y0 + 1})

      scan_point(program, {x, y0 + size - 1}) == 0 ->
        find_closest_square(program, size, start, x + 1)

      true ->
        {x, y0}
    end
  end

  def scanning(input) do
    receive do
      {:read_input, remote} ->
        [h | t] = input
        send(remote, h)
        scanning(t)
    end
  end

  defp scan_point(program, {x, y}) do
    scanner = spawn_link(__MODULE__, :scanning, [[x, y]])

    program
    |> Program.new(scanner, self())
    |> Program.execute()

    receive do
      {:write_output, value} -> value
    end
  end

  # very little help
  defp enable_grid_cache do
    {:ok, _} = Agent.start_link(fn -> %{} end, name: GridCache)
  end

  defp scan_point(program, coord, :cache_enabled) do
    case Agent.get(GridCache, fn grid -> grid[coord] end) do
      nil ->
        state = scan_point(program, coord)
        :ok = Agent.update(GridCache, fn grid -> Map.put(grid, coord, state) end)
        state

      state ->
        state
    end
  end

  defp display_grid(grid, size \\ 50) do
    0..(size - 1)
    |> Enum.each(fn y ->
      0..(size - 1)
      |> Enum.map(fn x ->
        case Map.fetch!(grid, {x, y}) do
          0 -> ?.
          1 -> ?#
        end
      end)
      |> IO.puts()
    end)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day17Test do
      use ExUnit.Case
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day17.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day17.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
