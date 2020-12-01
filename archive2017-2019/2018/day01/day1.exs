defmodule OldVersion do
  def frequence_of_seq(seq) do
    seq
    |> Enum.reduce(0, &+/2)
  end

  def repeated_frequency(input) do
    input
    |> frequency_seq_stream()
    |> Enum.find(fn {freq, occurs} ->
      Map.get(occurs, freq) == 2
    end)
    |> elem(0)
  end

  def frequency_seq_stream(input) do
    input
    |> Stream.transform({0, %{}}, fn i, {current_freq, occurs} ->
      new_occurs =
        occurs
        |> Map.update(current_freq, 1, &(&1 + 1))

      {[{current_freq, new_occurs}], {current_freq + i, new_occurs}}
    end)
  end

  def input_seq_from_file(file) do
    File.stream!(file)
    |> Stream.map(&Integer.parse/1)
    |> Enum.map(fn {n, _} -> n end)
  end
end

defmodule Day1 do
  # Based on Jose's approach
  def repeated_frequency(input) do
    input
    |> Enum.reduce_while({0, %{0 => true}}, fn n, {current_freq, seen_freqs} ->
      new_freq = n + current_freq

      case Map.get(seen_freqs, new_freq) do
        true -> {:halt, new_freq}
        _ -> {:cont, {new_freq, Map.put(seen_freqs, new_freq, true)}}
      end
    end)
  end
end

case System.argv() do
  [input_file] ->
    input_file
    |> File.stream!()
    |> Stream.map(fn line ->
      {integer, _} = Integer.parse(line)
      integer
    end)
    |> Stream.cycle()
    |> Day1.repeated_frequency()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "wrong usage")
end
