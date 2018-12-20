defmodule Day14 do
  def part1(input) do
    board = Board.new

    Board.process_while(board, fn new_board ->
      if new_board.total < input + 10 do
        :cont
      else
        {:halt, new_board.recipes |> RecipesTable.select_scores(input, input + 9) |> Enum.join("")}
      end
    end)
  end

  def part2(_input) do
  end
end

defmodule Board do
  defstruct [:current, :recipes, :total]

  def new do
    recipe1 = {0, 3}
    recipe2 = {1, 7}
    %Board{current: {recipe1, recipe2}, recipes: RecipesTable.new([recipe1, recipe2]), total: 2}
  end

  def process_while(board, fun) do
    case fun.(board) do
      :cont -> board |> make_recipes() |> change_current() |> process_while(fun)
      {:halt, result} -> result
    end
  end

  def make_recipes( board = %Board{current: {{_, score1}, {_, score2}}, total: total, recipes: recipes}) do
    case Integer.digits(score1 + score2) do
      [new_score] ->
        RecipesTable.add_recipe(recipes, {total, new_score})
        %Board{board | total: total + 1}

      [new_score1, new_score2] ->
        RecipesTable.add_recipe(recipes, {total, new_score1})
        RecipesTable.add_recipe(recipes, {total + 1, new_score2})
        %Board{board | total: total + 2}
    end
  end

  def change_current(board = %Board{current: {r1, r2}, recipes: recipes, total: total}) do
    %Board{board | current: {next_recipe(r1, total, recipes), next_recipe(r2, total, recipes)}}
  end

  defp next_recipe({index, score}, total, recipes) do
    new_index = rem(index + score + 1, total)
    {new_index, RecipesTable.get_score(recipes, new_index)}
  end
end

defmodule RecipesTable do
  def new(recipes) do
    table = :ets.new(nil, [:ordered_set, :protected])
    recipes
    |> Enum.each(& :ets.insert_new(table, &1))
    table
  end

  def add_recipe(recipes, recipe) do
    :ets.insert_new(recipes, recipe)
  end

  def get_score(table, index) do
    [{_, score}] = :ets.lookup(table, index)
    score
  end

  def select_scores(table, from, to) do
    :ets.select(table, [{{:"$1", :"$2"}, [{:andalso, {:>=, :"$1", from}, {:"=<", :"$1", to}}], [:"$2"]}])
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day14Test do
      use ExUnit.Case

      test "part 1 result" do
        assert "5158916779" == Day14.part1(9)
        assert "0124515891" == Day14.part1(5)
        assert "9251071085" == Day14.part1(18)
        assert "5941429882" == Day14.part1(2018)
      end

      test "part 2 result" do
        # assert 9 == Day14.part2("51589")
        # assert 5 == Day14.part2("01245")
        # assert 18 == Day14.part2("92510")
        # assert 2018 == Day14.part2("59414")
      end

      test "initial recipes" do
        assert %Board{total: 2, current: {{0, 3}, {1, 7}}} = Board.new()
      end

      test "make new recipes and change current" do
        board = Board.new()

        assert board = %Board{total: 4, current: {{0, 3}, {1, 7}}} = Board.make_recipes(board)

        assert board = %Board{total: 4, current: {{0, 3}, {1, 7}}} = Board.change_current(board)

        assert board = %Board{total: 6, current: {{0, 3}, {1, 7}}} = Board.make_recipes(board)

        assert board = %Board{total: 6, current: {{4, 1}, {3, 0}}} = Board.change_current(board)
      end
    end

  [input, "--part1"] ->
    input
    |> String.to_integer()
    |> Day14.part1()
    |> IO.inspect()

  [input, "--part2"] ->
    input
    |> String.to_integer()
    |> Day14.part2()
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input_file]")
end
