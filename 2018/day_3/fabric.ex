defmodule Claim do
  defstruct [:id, :x, :y, :width, :height, :coords]

  def parse(row) do
    [[id, x, y, width, height]] =
      Regex.scan(~r/^#(\d+)\s\@\s+(\d+),(\d+):\s(\d+)x(\d+)/, row, capture: :all_but_first)

    claim = %Claim{
      id: id,
      x: x |> Integer.parse() |> elem(0),
      y: y |> Integer.parse() |> elem(0),
      width: width |> Integer.parse() |> elem(0),
      height: height |> Integer.parse() |> elem(0)
    }

    claim |> Map.put(:coords, calc_coords(claim))
  end

  def find_special([h | t]) do
    do_find_special(h, t, [])
  end

  defp do_find_special(_, [], _), do: nil

  defp do_find_special(guess, possible, failures) do
    case {Enum.reduce(possible, {[], []}, fn compared_one, {overlaps, no_overlaps} ->
            cond do
              overlap?(guess, compared_one) -> {[compared_one | overlaps], no_overlaps}
              true -> {overlaps, [compared_one | no_overlaps]}
            end
          end), Enum.any?(failures, &overlap?(&1, guess))} do
      {{[], _}, false} ->
        guess

      {{overlaps, [next | remaining_possible]}, _} ->
        do_find_special(next, remaining_possible, overlaps ++ failures)
    end
  end

  def overlap?(%Claim{coords: coords1}, %Claim{coords: coords2}) do
    overlap?(coords1, coords2)
  end

  def overlap?(_, []), do: false

  def overlap?(coords1, [first | rest]) do
    cond do
      first in coords1 -> true
      true -> overlap?(coords1, rest)
    end
  end

  def calc_coords(%Claim{x: x, y: y, width: w, height: h}) do
    for i <- x..(x + w - 1), j <- y..(y + h - 1), do: {i, j}
  end
end

defmodule Fabric do
  def overlap_inches(input) do
    input
    |> Enum.reduce(%{}, fn row, result ->
      row
      |> Claim.parse()
      |> Map.fetch!(:coords)
      |> Enum.reduce(result, fn coord, new_result ->
        new_result
        |> Map.update(coord, 1, &(&1 + 1))
      end)
    end)
    |> Enum.count(fn {_, cnt} -> cnt > 1 end)
  end

  def get_input(file \\ "input.txt") do
    File.stream!(file)
  end
end
