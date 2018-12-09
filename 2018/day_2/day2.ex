defmodule Day2 do
  def checksum(data) do
    {times_of_2, times_of_3} =
      Enum.reduce(data, {0, 0}, fn str, result = {times_of_2, times_of_3} ->
        dups_count = count_letters(str)

        case {MapSet.member?(dups_count, 2), MapSet.member?(dups_count, 3)} do
          {true, true} -> {times_of_2 + 1, times_of_3 + 1}
          {true, false} -> {times_of_2 + 1, times_of_3}
          {false, true} -> {times_of_2, times_of_3 + 1}
          _ -> result
        end
      end)

    times_of_2 * times_of_3
  end

  def count_letters(str) do
    str
    |> String.graphemes()
    |> Enum.group_by(& &1)
    |> Enum.reduce_while(MapSet.new(), fn {_, n}, set ->
      cond do
        MapSet.member?(set, 2) && MapSet.member?(set, 3) -> {:halt, set}
        true -> {:cont, MapSet.put(set, length(n))}
      end
    end)
  end

  def part2(input) do
    find_common_string(input)
  end

  def find_common_string([head | tail]) do
    Enum.find_value(tail, &(one_difference_string(&1, head))) || find_common_string(tail)
  end

  def one_difference_string(l1, l2) do
    one_difference_string(l1, l2, [], 0)
  end

  def one_difference_string([], [], same_chars, 1), do: same_chars |> Enum.reverse() |> to_string()
  def one_difference_string([h | t1], [h | t2], same_chars, diff_count) do
    one_difference_string(t1, t2, [h | same_chars], diff_count)
  end
  def one_difference_string([_h1 | t1], [_h2 | t2], same_chars, 0), do: one_difference_string(t1, t2, same_chars, 1)
  def one_difference_string(_, _, _, _), do: nil
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day4Test do
      use ExUnit.Case

      @input """
      abcde
      fghij
      klmno
      pqrst
      fguij
      axcye
      wvxyz
      """
      test "part 2" do
        assert "fgij" == Day2.part2(@input |> String.split("\n", trim: true) |> Enum.map(&to_charlist/1))
      end
    end

  [input_file] ->
    input_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&to_charlist/1)
    |> Day2.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "wrong usage")
end
