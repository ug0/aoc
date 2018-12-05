defmodule Inventory do
  def checksum(data) do
    {times_of_2, times_of_3} = Enum.reduce(data, {0, 0}, fn str, result = {times_of_2, times_of_3} ->
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
    |> Enum.group_by(&(&1))
    |> Enum.reduce(MapSet.new, fn {_, n}, set ->
      MapSet.put(set, length(n))
    end)
  end

  def part2(input) do
    {id1, id2} = find_boxes(input)
    Stream.zip(String.graphemes(id1), String.graphemes(id2))
    |> Stream.reject(fn {x, y} -> x != y end)
    |> Stream.map(fn {x, _} -> x end)
    |> Enum.join()
  end
  def find_boxes([_ | []]), do: nil
  def find_boxes([first | rest]) do
    case Enum.find(rest, fn id -> ids_diff(first, id) == 1 end) do
      nil -> find_boxes(rest)
      match -> {first, match}
    end
  end

  def ids_diff(id1, id2) do
    Stream.zip(String.graphemes(id1), String.graphemes(id2))
    |> Enum.count(fn {x, y} -> x != y end)
  end

  def get_input(file \\ "input.txt") do
    File.stream!(file)
    |> Enum.map(&String.trim_trailing/1)
  end
end
