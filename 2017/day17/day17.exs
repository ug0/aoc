defmodule Day17 do
  alias __MODULE__.CircularBuffer, as: Buffer

  def part1(steps) do
    2017
    |> run(steps)
    |> Buffer.move_forward(1)
    |> Buffer.current()
  end

  def part2(steps) do
    # part2_slow(steps)
    part2_fast(steps)
  end

  # Only track insertions afer zero-index, much faster.
  def part2_fast(steps) do
    1..50_000_000
    |> Enum.reduce({[], 0, 1}, fn value, {track, pos, len} ->
      case next_pos(pos, steps, len) do
        0 -> {[value | track], 1, len + 1}
        pos -> {track, pos + 1, len + 1}
      end
    end)
    |> elem(0)
    |> hd()
  end

  defp next_pos(pos, steps, len) do
    rem(pos + steps, len)
  end

  # Simuate the process as part1 does, very slow.
  def part2_slow(steps) do
    50_000_000
    |> run(steps)
    |> move_to_zero()
    |> Buffer.move_forward(1)
    |> Buffer.current()
  end

  defp move_to_zero(%{current: 0} = buffer) do
    buffer
  end

  defp move_to_zero(buffer) do
    buffer
    |> Buffer.move_forward(1)
    |> move_to_zero()
  end

  defp run(times, steps) do
    1..times
    |> Enum.reduce(Buffer.new(), fn v, buffer ->
      buffer
      |> Buffer.move_forward(steps)
      |> Buffer.insert_after(v)
      |> Buffer.move_forward(1)
    end)
  end

  defmodule CircularBuffer do
    defstruct [:current, :left, :right]

    def new do
      %__MODULE__{current: 0, left: [], right: []}
    end

    def current(%__MODULE__{current: current}) do
      current
    end

    def move_forward(%__MODULE__{} = buffer, 0) do
      buffer
    end

    def move_forward(%__MODULE__{} = buffer, steps) do
      buffer
      |> move_forward_one_step()
      |> move_forward(steps - 1)
    end

    defp move_forward_one_step(%__MODULE__{left: left, current: current, right: []}) do
      [current | right] = Enum.reverse([current | left])

      %__MODULE__{left: [], current: current, right: right}
    end

    defp move_forward_one_step(%__MODULE__{left: left, current: current, right: [next | right]}) do
      %__MODULE__{left: [current | left], current: next, right: right}
    end

    def insert_after(%__MODULE__{right: right} = buffer, value) do
      %__MODULE__{buffer | right: [value | right]}
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day17Test do
      use ExUnit.Case

      @steps 3
      test "part1 result" do
        assert Day17.part1(@steps) == 638
      end
    end

  [input, "--part1"] ->
    input
    |> String.to_integer()
    |> Day17.part1()
    |> IO.puts()

  [input, "--part2"] ->
    input
    |> String.to_integer()
    |> Day17.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input] --flag")
end
