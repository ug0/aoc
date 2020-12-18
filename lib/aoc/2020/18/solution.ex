defmodule Aoc.Y2020.D18 do
  use Aoc.Input

  def part1 do
    input()
    |> String.splitter("\n", trim: true)
    |> Stream.map(&evaluate_expression/1)
    |> Enum.sum()
    |> IO.inspect()
  end

  def part2 do
    input()
    |> String.splitter("\n", trim: true)
    |> Stream.map(&evaluate_expression(&1, op_priority: true))
    |> Enum.sum()
    |> IO.inspect()
  end

  def evaluate_expression(expr, opts \\ []) do
    op_compare_fun =
      if Keyword.get(opts, :op_priority, false) do
        fn
          "+", "*" -> :gt
          "*", "+" -> :lt
          _, _ -> :eq
        end
      else
        fn _, _ -> :eq end
      end

    expr
    |> serialize()
    |> process_parentheses()
    |> eval(op_compare_fun)
  end

  defp eval(num, _) when is_integer(num) do
    num
  end

  defp eval(num, _) when is_binary(num) do
    String.to_integer(num)
  end

  defp eval({op, left, right}, op_compare_fun) do
    operation(op).(eval(left, op_compare_fun), eval(right, op_compare_fun))
  end

  defp eval([left, op, right | rest], op_compare_fun) do
    eval(rest, {op, left, right}, op_compare_fun)
  end

  defp eval([], expr, op_compare_fun) do
    eval(expr, op_compare_fun)
  end

  defp eval([next_op, next_expr | rest], {op, left, right} = expr, op_compare_fun) do
    case op_compare_fun.(next_op, op) do
      :gt -> eval(rest, {op, left, {next_op, right, next_expr}}, op_compare_fun)
      _ -> eval(rest, {next_op, eval(expr, op_compare_fun), next_expr}, op_compare_fun)
    end
  end

  defp operation("+"), do: &(&1 + &2)
  defp operation("*"), do: &(&1 * &2)

  defp serialize(expr) do
    expr
    |> String.replace(" ", "")
    |> String.split(~r/[^\d]/, include_captures: true, trim: true)
  end

  defp process_parentheses(expr) do
    process_parentheses(expr, [])
  end

  defp process_parentheses([], result) do
    Enum.reverse(result)
  end

  defp process_parentheses(["(" | rest], result) do
    {inner_expr, rest} = extract_inner_expr(rest, [], 0)
    process_parentheses(rest, [inner_expr | result])
  end

  defp process_parentheses([next | rest], result) do
    process_parentheses(rest, [next | result])
  end

  defp extract_inner_expr([")" | rest], inner_expr, 0) do
    {process_parentheses(Enum.reverse(inner_expr)), rest}
  end

  defp extract_inner_expr([next | rest], inner_expr, count) do
    extract_inner_expr(rest, [next | inner_expr], update_parentheses_count(count, next))
  end

  defp update_parentheses_count(count, "("), do: count + 1
  defp update_parentheses_count(count, ")"), do: count - 1
  defp update_parentheses_count(count, _), do: count
end
