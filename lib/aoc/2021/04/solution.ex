defmodule Aoc.Y2021.D04 do
  use Aoc.Input

  defmodule Board do
    defstruct [:grid, :marked, :hits, :won?]

    @win_hits 5

    def new(rows) do
      grid =
        rows
        |> Stream.map(&Enum.with_index/1)
        |> Stream.with_index()
        |> Stream.flat_map(fn {columns, col} ->
          Enum.map(columns, fn {num, row} -> {num, {row, col}} end)
        end)
        |> Enum.into(%{})

      %__MODULE__{grid: grid, marked: [], hits: %{}, won?: false}
    end

    def mark(%__MODULE__{grid: grid, hits: hits, marked: marked} = board, num) do
      case grid do
        %{^num => {row, col}} ->
          new_hits =
            [{:row, row}, {:col, col}]
            |> Enum.reduce(hits, fn key, acc ->
              Map.update(acc, key, 1, &(&1 + 1))
            end)

          %__MODULE__{
            board
            | marked: [num | marked],
              hits: new_hits,
              won?: @win_hits in [new_hits[{:row, row}], new_hits[{:col, col}]]
          }

        _ ->
          board
      end
    end

    def unmarked_numbers(%__MODULE__{grid: grid, marked: marked}) do
      Map.keys(grid) -- marked
    end
  end

  alias __MODULE__.Board

  def part1(str \\ nil) do
    {numbers, boards} = parse_input(str || input())

    boards
    |> Enum.map(&Board.new/1)
    |> get_first_winner(numbers)
    |> final_score()
    |> IO.inspect()
  end

  defp get_first_winner(boards, [first | rest]) do
    case Enum.find(boards, fn board -> board.won? end) do
      nil ->
        boards |> Enum.map(&Board.mark(&1, first)) |> get_first_winner(rest)

      winner ->
        winner
    end
  end

  def part2(str \\ nil) do
    {numbers, boards} = parse_input(str || input())

    boards
    |> Enum.map(&Board.new/1)
    |> get_last_winner(numbers)
    |> final_score()
    |> IO.inspect()
  end

  defp get_last_winner(boards, [first| rest]) do
    case(Enum.split_with(boards, & &1.won?)) do
      {winners, []} -> Enum.at(winners, -1)
      {_winners, ongoing} -> ongoing |> Enum.map(&Board.mark(&1, first)) |> get_last_winner(rest)
    end
  end

  defp final_score(winner) do
    winner
    |> Board.unmarked_numbers()
    |> Enum.sum()
    |> Kernel.*(hd(winner.marked))
  end

  defp parse_input(str) do
    [numbers | boards] = String.split(str, "\n\n", trim: true)

    {
      numbers |> String.splitter(",") |> Enum.map(&String.to_integer/1),
      boards
      |> Enum.map(fn str ->
        str
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          line |> String.splitter(" ", trim: true) |> Enum.map(&String.to_integer/1)
        end)
      end)
    }
  end
end
