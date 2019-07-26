defmodule Day10 do
  def part1(input, size \\ 256) do
    size_list =
      input
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    [x, y] =
      size
      |> initial_ring()
      |> process(size_list)
      |> take_sequential(2)

    x * y
  end

  @appendix [17, 31, 73, 47, 23]
  def part2(input) do
    size_list =
      input
      |> String.trim()
      |> to_charlist()

    initial_ring()
    |> process(size_list ++ @appendix, 64)
    |> hash_digest()
  end

  defp initial_ring(size \\ 256) do
    0..(size - 1)
    |> Stream.with_index()
    |> Enum.into(%{})
  end

  use Bitwise, only_operators: true

  defp hash_digest(ring) do
    ring
    |> take_sequential(256)
    |> Stream.chunk_every(16)
    |> Stream.map(fn group ->
      Enum.reduce(group, &(&1 ^^^ &2))
    end)
    |> Stream.map(&num_to_two_digits_hex/1)
    |> Enum.join()
  end

  defp num_to_two_digits_hex(num) do
    num
    |> Integer.to_string(16)
    |> String.pad_leading(2, "0")
    |> String.downcase()
  end

  defp take_sequential(ring, num) do
    Enum.map(0..(num - 1), &Map.fetch!(ring, &1))
  end

  defp process(ring, size_list, rounds \\ 1) do
    {ring, _, _} =
      Enum.reduce(1..rounds, {ring, 0, 0}, fn _round, acc ->
        round(acc, size_list)
      end)
    ring
  end

  defp round({_ring, _pos, _skip_size} = init_state, size_list) do
     Enum.reduce(size_list, init_state, fn size, {ring, pos, skip_size} ->
      {reverse(ring, pos, pos + size - 1), pos + size + skip_size, skip_size + 1}
    end)
  end

  defp reverse(ring, from, to) do
    for(i <- from..to, do: {from + to - i, ring_get(ring, i)})
    |> Enum.reduce(ring, fn {i, v}, acc ->
      ring_put(acc, i, v)
    end)
  end

  defp ring_get(ring, i) do
    Map.fetch!(ring, ring_offset(ring, i))
  end

  defp ring_put(ring, i, v) do
    Map.put(ring, ring_offset(ring, i), v)
  end

  defp ring_offset(ring, offset) when offset < 0 do
    ring_offset(ring, offset + map_size(ring))
  end

  defp ring_offset(ring, offset) do
    rem(offset, map_size(ring))
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day10Test do
      use ExUnit.Case

      test "part1 result" do
        assert Day10.part1("3,4,1,5", 5) == 12
      end

      test "part2 result" do
        assert Day10.part2("") == "a2582a3a0e66e6e86e3812dcb672a272"
        assert Day10.part2("AoC 2017") == "33efeb34ea91902bb2f59c9920caa6cd"
        assert Day10.part2("1,2,3") == "3efbe78a8d82f29979031a4aa0b16a9d"
        assert Day10.part2("1,2,4") == "63960835bcdc130f0b66d7ff4f6a5a8e"
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day10.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day10.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
