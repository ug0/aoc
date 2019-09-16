defmodule Day14 do
  @size 128
  def part1(input) do
    0..(@size - 1)
    |> Stream.map(row_digits_parser(input))
    |> Stream.map(&Enum.sum/1)
    |> Enum.sum()
  end

  def part2(input) do
    0..(@size - 1)
    |> Stream.map(row_digits_parser(input))
    |> to_digits_map()
    |> calc_present_regions()
  end

  defp calc_present_regions(map) do
    calc_present_regions(map, Map.keys(map), MapSet.new(), 0)
  end

  defp calc_present_regions(_map, _unchecked = [], _checked, count) do
    count
  end

  defp calc_present_regions(map, _unchecked = [next | rest], checked, count) do
    if !MapSet.member?(checked, next) && map[next] == 1 do
      calc_present_regions(map, rest, MapSet.union(checked, connected_squares(next, &(map[&1] == 1))), count + 1)
    else
      calc_present_regions(map, rest, checked, count)
    end
  end

  defp connected_squares(pos, filter) do
    connected_squares([pos], MapSet.new(), filter)
  end

  defp connected_squares([], result, _filter) do
    result
  end

  defp connected_squares([next | rest], result, filter) do
    if MapSet.member?(result, next) do
      connected_squares(rest, result, filter)
    else
      neighbors = next |> adjacents() |> Enum.filter(filter)
      connected_squares(neighbors ++ rest, MapSet.put(result, next), filter)
    end
  end

  defp adjacents({row, col}) do
    for i <- [1, 0, -1],
        j <- [1, 0, -1],
        abs(i) + abs(j) == 1,
        row + i >= 0,
        row + i < @size,
        col + j >= 0,
        col + j < @size do
      {row + i, col + j}
    end
  end

  defp to_digits_map(matrix_stream) do
    matrix_stream
    |> Stream.map(&Enum.with_index/1)
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {digits_row, row}, acc ->
      Enum.into(digits_row, acc, fn {digit, col} ->
        {{row, col}, digit}
      end)
    end)
  end

  defp row_digits_parser(input) do
    fn n ->
      input
      |> get_row(n)
      |> hash()
      |> hash_digits_stream()
    end
  end

  defp hash(input) do
    KnotHash.result(input)
  end

  defp hash_digits_stream(hash) do
    hash
    |> String.splitter("", trim: true)
    |> Stream.flat_map(fn hex ->
      hex
      |> Integer.parse(16)
      |> elem(0)
      |> Integer.to_string(2)
      |> String.pad_leading(4, "0")
      |> String.splitter("", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp get_row(hash, n) do
    "#{hash}-#{n}"
  end
end

# Copy from day10
defmodule KnotHash do
  @appendix [17, 31, 73, 47, 23]
  def result(input) do
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

  defp process(ring, size_list, rounds) do
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

    defmodule Day14Test do
      use ExUnit.Case

      @input "flqrgnkx"
      test "part1 result" do
        assert Day14.part1(@input) == 8108
      end

      test "part2 result" do
        assert Day14.part2(@input) == 1242
      end
    end

  [input, "--part1"] ->
    input
    |> Day14.part1()
    |> IO.puts()

  [input, "--part2"] ->
    input
    |> Day14.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input] --flag")
end
