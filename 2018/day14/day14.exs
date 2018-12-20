defmodule Day14 do
  def part1(input) do
    board = Board.new()

    Board.process_while(board, fn new_board ->
      if new_board.total < input + 10 do
        :cont
      else
        {:halt, new_board.recipes |> RecipesTable.select_scores(input, input + 9) |> Enum.join("")}
      end
    end)
  end

  def part2(digits) do
    board = Board.new(length(digits) + 1)

    Board.process_while(board, fn new_board ->
      if RecipesTable.tail_match?(new_board.recipes, digits) do
        tail_queue = new_board.recipes.tail.tail
        {:halt,
          case {hd(digits), new_board.recipes |> RecipesTable.tail_scores() |> hd()} do
            {digit, digit} -> tail_queue |> :queue.head() |> elem(0)
            _ -> tail_queue |> :queue.drop() |> :queue.head() |> elem(0)
          end}
      else
        :cont
      end
    end)
  end
end

defmodule Board do
  alias RecipesTail, as: Tail

  defstruct [:current, :recipes, :total]

  def new(max_tail_length \\ nil) do
    recipe1 = {0, 3}
    recipe2 = {1, 7}

    %Board{
      current: {recipe1, recipe2},
      recipes: RecipesTable.new([recipe1, recipe2], max_tail_length),
      total: 2
    }
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
        %Board{board | total: total + 1, recipes: RecipesTable.add_recipe(recipes, {total, new_score})}

      [new_score1, new_score2] ->
        new_recipes = recipes
        |> RecipesTable.add_recipe({total, new_score1})
        |> RecipesTable.add_recipe({total + 1, new_score2})

        %Board{board | total: total + 2, recipes: new_recipes}
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
  alias RecipesTail, as: Tail
  alias RecipesTable, as: Table

  defstruct [:recipes, :tail]

  def new(recipes, max_tail_length \\ nil) do
    table = :ets.new(nil, [:ordered_set, :protected])
    recipes
    |> Enum.each(& :ets.insert_new(table, &1))
    %RecipesTable{recipes: table, tail: Tail.new(recipes, max_tail_length)}
  end

  def add_recipe(table = %Table{recipes: recipes, tail: tail}, recipe) do
    :ets.insert_new(recipes, recipe)

    %Table{table | tail: Tail.add(tail, recipe)}
  end

  def get_score(%Table{recipes: recipes}, index) do
    [{_, score}] = :ets.lookup(recipes, index)
    score
  end

  def select_scores(%Table{recipes: recipes}, from, to) do
    :ets.select(recipes, [{{:"$1", :"$2"}, [{:andalso, {:>=, :"$1", from}, {:"=<", :"$1", to}}], [:"$2"]}])
  end

  def tail_scores(%RecipesTable{tail: tail}) do
    Tail.scores(tail)
  end

  def tail_match?(%RecipesTable{tail: tail}, digits) do
    Tail.match_scores?(tail, digits)
  end
end

defmodule RecipesTail do
  alias RecipesTail, as: Tail

  defstruct [:tail, :max_length]

  def new(_, nil), do: nil
  def new(recipes, max_length) do
    %Tail{
      tail: recipes |> Enum.reduce(:queue.new(), fn recipe, queue ->
              :queue.in(recipe, queue)
            end),
      max_length: max_length
    }
  end

  def scores(%Tail{tail: tail}) do
    tail
    |> :queue.to_list()
    |> Enum.map(fn {_, score} -> score end)
  end

  def add(recipes_tail = %Tail{tail: tail, max_length: max_length}, recipe) do
    new_tail = case :queue.len(tail) do
      ^max_length -> :queue.in(recipe, :queue.drop(tail))
      _ -> :queue.in(recipe, tail)
    end
    %Tail{recipes_tail | tail: new_tail}
  end

  def add(_, _), do: nil

  def match_scores?(tail = %Tail{}, digits) do
    tail
    |> scores()
    |> match_score_digits?(digits)
  end

  defp match_score_digits?([], _), do: false
  defp match_score_digits?(digits1, digits2) do
    :lists.prefix(digits2, digits1) || match_score_digits?(tl(digits1), digits2)
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
        assert 9 == Day14.part2(51589 |> Integer.digits())
        assert 5 == Day14.part2([0, 1, 2, 4, 5])
        assert 18 == Day14.part2(92510 |> Integer.digits())
        assert 2018 == Day14.part2(59414 |> Integer.digits())
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

      test "recipes tail" do
        tail = RecipesTail.new([{0, 3}, {1, 7}], 3)

        tail = RecipesTail.add(tail, {2, 1})
        assert [3, 7, 1] == RecipesTail.scores(tail)

        tail = RecipesTail.add(tail, {3, 0})
        assert [7, 1, 0] == RecipesTail.scores(tail)

        assert RecipesTail.match_scores?(tail, [7, 1, 0])
        assert RecipesTail.match_scores?(tail, [7, 1])
        assert RecipesTail.match_scores?(tail, [1, 0])
        refute RecipesTail.match_scores?(tail, [7, 0])
        refute RecipesTail.match_scores?(tail, [7, 0, 1])
        refute RecipesTail.match_scores?(tail, [6, 1, 0])
      end
    end

  [input, "--part1"] ->
    input
    |> String.to_integer()
    |> Day14.part1()
    |> IO.inspect()

  [input, "--part2"] ->
    input
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Day14.part2()
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input_file]")
end
