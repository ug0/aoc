defmodule Day7 do
  def part1(lines) do
    {all_steps, requirements} = parse_requirements(lines)
    plan_steps([], MapSet.to_list(all_steps) |> Enum.sort(), requirements)
  end

  def part2(lines) do
  end

  def plan_steps(sorted_steps, all_steps, _) when length(sorted_steps) == length(all_steps),
    do: sorted_steps |> Enum.reverse()

  def plan_steps(sorted_steps, all_steps, requirements) do
    next_step =
      all_steps
      |> Stream.filter(&(&1 not in sorted_steps))
      |> Enum.find(&all_required_steps_done?(&1, sorted_steps, requirements))

    plan_steps([next_step | sorted_steps], all_steps, requirements)
  end

  def all_required_steps_done?(step, done_steps, requirements) do
    case requirements |> Map.get(step) do
      nil -> true
      required_steps -> MapSet.subset?(required_steps, MapSet.new(done_steps))
    end
  end

  def parse_requirements(lines) do
    lines
    |> Stream.map(&parse_line/1)
    |> Enum.reduce({MapSet.new(), %{}}, fn {step, required_step}, {all_steps, requirements} ->
      new_requirements =
        requirements
        |> Map.update(step, MapSet.new([required_step]), &MapSet.put(&1, required_step))

      new_all_steps = all_steps |> MapSet.put(step) |> MapSet.put(required_step)
      {new_all_steps, new_requirements}
    end)
  end

  def parse_line(line) do
    case Regex.scan(~r/Step\s([A-Z]).+step\s([A-Z])\scan/, line, capture: :all_but_first) do
      [[required_step, step]] -> {step, required_step}
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day5Test do
      use ExUnit.Case

      @input """
      Step C must be finished before step A can begin.
      Step C must be finished before step F can begin.
      Step A must be finished before step B can begin.
      Step A must be finished before step D can begin.
      Step B must be finished before step E can begin.
      Step D must be finished before step E can begin.
      Step F must be finished before step E can begin.
      """
      test "part1 result" do
        assert "CABDFE" == Day7.part1(@input |> String.split("\n", trim: true)) |> Enum.join()
      end

      test "part 2 result" do
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.stream!()
    |> Day7.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.stream!()
    |> Day7.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
