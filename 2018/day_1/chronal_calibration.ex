defmodule ChronalCalibration do
  def frequence_of_seq(seq) do
    seq
    |> Enum.reduce(0, &+/2)
  end

  def first_frequency_reached_twice(seq) do
    seq
    |> Stream.cycle()
    |> frequency_seq_stream()
    |> Enum.find(fn {freq, occurs} ->
      Map.get(occurs, freq) == 2
    end)
    |> elem(0)
  end

  def frequency_seq_stream(cycle) do
    cycle
    |> Stream.transform({0, %{}}, fn i, acc = {current_freq, occurs} ->
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
