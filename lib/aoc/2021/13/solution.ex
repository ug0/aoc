defmodule Aoc.Y2021.D13 do
  use Aoc.Input

  defmodule Paper do
    def new(dots) do
      dots
    end

    def to_s(paper) do
      {{min_x, _}, {max_x, _}} = Enum.min_max_by(paper, fn {x, _} -> x end)
      {{_, min_y}, {_, max_y}} = Enum.min_max_by(paper, fn {_, y} -> y end)

      map = Enum.into(paper, %{}, fn {x, y} -> {{x, y}, ?#} end)

      min_y..max_y
      |> Stream.map(fn y ->
        min_x..max_x
        |> Enum.map(fn x ->
          Map.get(map, {x, y}, ?\s)
        end)
        |> to_string()
      end)
      |> Enum.join("\n")
    end

    def fold(paper, {:x, n}) do
      trans(paper, fn {x, _y} -> x > n end, fn {x, y} ->  {2 * n - x, y} end)
    end

    def fold(paper, {:y, n}) do
      trans(paper, fn {_x, y} -> y > n end, fn {x, y} ->  {x, 2 * n - y} end)
    end

    defp trans(paper, filter_fun, change_fun) do
      {to_trans, stay} = Enum.split_with(paper, filter_fun)
      Enum.uniq(stay ++ Enum.map(to_trans, change_fun))
    end
  end

  alias __MODULE__.Paper

  def part1(str \\ nil) do
    {dots, instructions} =
      (str || input())
      |> parse_input()

    dots
    |> Paper.new()
    |> Paper.fold(hd(instructions))
    |> length()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    {dots, instructions} =
      (str || input())
      |> parse_input()

    instructions
    |> Enum.reduce(Paper.new(dots), fn i, acc ->
      Paper.fold(acc, i)
     end)
    |> Paper.to_s()
    |> IO.puts()
  end

  defp parse_input(str) do
    [paper_str, instructions_str] = String.split(str, "\n\n", trim: true)

    {
      paper_str
      |> String.splitter("\n", trim: true)
      |> Enum.map(fn s ->
        s |> String.splitter(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
      end),
      instructions_str
      |> String.splitter("\n", trim: true)
      |> Enum.map(fn
        "fold along y=" <> n -> {:y, String.to_integer(n)}
        "fold along x=" <> n -> {:x, String.to_integer(n)}
      end)
    }
  end
end
