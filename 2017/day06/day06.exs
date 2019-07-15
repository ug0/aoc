defmodule Day6 do
  def part1(input) do
    {_dist, [second, _first]} =
      input
      |> parse_banks()
      |> redistribute_til_repeat_once()

    second
  end

  def part2(input) do
    {_dist, [third, second, _first]} =
      input
      |> parse_banks()
      |> redistribute_til_repeat_twice()

    third - second
  end

  defp parse_banks(input) do
    input
    |> String.trim()
    |> String.split([" ", "\t"], trim: true)
    |> Stream.with_index()
    |> Stream.map(fn {n, i} -> {i, String.to_integer(n)} end)
    |> Enum.into(%{})
  end

  defp redistribute(banks) do
    {i, n} = bank_with_max_memory(banks)
    num_of_banks = map_size(banks)

    Enum.reduce(1..n, update_bank(banks, i, fn _ -> 0 end), fn offset, acc ->
      update_bank(acc, rem(offset + i, num_of_banks), &(&1 + 1))
    end)
  end

  defp redistribute_til_repeat_once(banks) do
    redistribute_while(banks, fn seen, {banks, step} ->
      case seen do
        %{^banks => [_first] = steps} -> {:halt, {banks, [step | steps]}}
        _ -> :cont
      end
    end)
  end

  defp redistribute_til_repeat_twice(banks) do
    redistribute_while(banks, fn seen, {banks, step} ->
      case seen do
        %{^banks => [_second, _first] = steps} -> {:halt, {banks, [step | steps]}}
        _ -> :cont
      end
    end)
  end

  defp redistribute_while(banks, fun) do
    redistribute_while(banks, %{}, 0, fun)
  end

  defp redistribute_while(banks, seen, step, fun) do
    seen = Map.update(seen, banks, [step], &[step | &1])
    dist = redistribute(banks)
    step = step + 1

    case fun.(seen, {dist, step}) do
      :cont -> redistribute_while(dist, seen, step, fun)
      {:halt, result} -> result
    end
  end

  defp bank_with_max_memory(banks) do
    Enum.max_by(banks, fn {_i, n} -> n end)
  end

  defp update_bank(banks, i, fun) do
    Map.update!(banks, i, fun)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day6Test do
      use ExUnit.Case

      @input """
      0 2 7 0
      """
      test "part1 result" do
        assert Day6.part1(@input) == 5
      end

      test "part2 result" do
        assert Day6.part2(@input) == 4
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day6.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day6.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
