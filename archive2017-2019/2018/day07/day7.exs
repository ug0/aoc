defmodule Day7 do
  @doc """
  1. 分析输入数据，得出各步骤所需前置步骤的一个 map(hash table)
  2. 以一个空 list 开始，逐步添加下一个可执行的步骤（字母顺序优先），直到所有步骤均已被添加
  """
  def part1(lines) do
    {all_steps, requirements} = parse_requirements(lines)
    plan_linear_steps([], MapSet.to_list(all_steps) |> Enum.sort(), requirements)
  end

  @doc """
  1. 首先实现一个 Workers 结构, 接收 worker 数量作为参数初始化。记录每个 worker 的任务分配及进展情况，并且可以实现以下功能：
      a. 为空闲 worker 分配新任务并返回分配结果（未成功分配的任务，更新后的 workers 结构）
      b. 让所有 workers 执行任务直到有任务（可能有多个）完成，返回结果（所花时间，完成的任务，更新后的 workers 结构）
  2. 解析输入文本，得到各任务以及所需时间和相互依赖关系。
  3. 初始化 workers，递归的执行以下过程直到所有任务完成，返回所花时间：
      a. 得到当前可以分配的任务（前置任务均已完成），分配任务
      b. 执行任务
      c. 更新任务完成情况，继续 a.
  """
  def part2(lines, workers \\ 5, base_seconds \\ 60) do
    {all_steps, requirements} = parse_requirements(lines)
    Workers.working(
      all_steps |> Enum.map(&{&1, base_seconds + step_time(&1)}),
      [],
      Workers.new(workers),
      fn step, done_steps -> all_required_steps_done?(step, done_steps, requirements) end,
      0
    )
  end

  def plan_linear_steps(sorted_steps, all_steps, _) when length(sorted_steps) == length(all_steps),
    do: sorted_steps |> Enum.reverse()

  def plan_linear_steps(sorted_steps, all_steps, requirements) do
    next_step =
      all_steps
      |> Stream.filter(&(&1 not in sorted_steps))
      |> Enum.find(&all_required_steps_done?(&1, sorted_steps, requirements))

    plan_linear_steps([next_step | sorted_steps], all_steps, requirements)
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

  def step_time(<<step::8>>), do: (step - ?A) + 1

  def parse_line(line) do
    case Regex.scan(~r/Step\s([A-Z]).+step\s([A-Z])\scan/, line, capture: :all_but_first) do
      [[required_step, step]] -> {step, required_step}
    end
  end
end

defmodule Workers do
  def new(num) when num > 0 do
    1..num |> Stream.map(&{&1, nil}) |> Enum.into(%{})
  end

  def working([], _, _, _, spent_minutes), do: spent_minutes
  def working(left_tasks, done_tasks, workers, task_assignable_checker, spent_minutes) do
    case left_tasks |> Enum.split_with(fn {task, _} -> task_assignable_checker.(task, done_tasks) end) do
      {[], _} ->
        start_working(left_tasks, done_tasks, workers, task_assignable_checker, spent_minutes)
      {assignable_tasks, other_tasks} ->
        {unassigned_tasks, new_workers} = assign_work(workers, assignable_tasks)
        start_working(unassigned_tasks ++ other_tasks, done_tasks, new_workers, task_assignable_checker, spent_minutes)
    end
  end

  def start_working(left_tasks, done_tasks, workers, task_assignable_checker, spent_minutes) do
    {mins, {new_done_tasks, new_workers}} = work_till_next_done(workers)
    working(left_tasks, new_done_tasks ++ done_tasks, new_workers, task_assignable_checker, mins + spent_minutes)
  end

  def assign_work(workers, tasks) do
    workers
    |> Enum.reduce_while({tasks, workers}, fn
      _, {[], workers} ->  {:halt, {[], workers}}
      {worker, nil}, {[{task, mins} | left_tasks], workers} -> {:cont, {left_tasks, %{workers | worker => {task, mins}}}}
      _, acc -> {:cont, acc}
    end)
  end

  def work_till_next_done(workers) do
    case next_done_minutes(workers) do
      nil -> nil
      spent_mins -> {spent_mins, Enum.reduce(workers, {[], workers}, fn
        {_worker, nil}, acc -> acc
        {worker, {task, ^spent_mins}}, {done, workers} -> {[task | done], %{workers | worker => nil}}
        {worker, {task, mins_left}}, {done, workers} -> {done, %{workers | worker => {task, mins_left - spent_mins}}}
      end)}
    end
  end

  defp next_done_minutes(workers) do
    case workers |> Enum.min_by(fn
      {_, nil} -> nil
      {_, {_, min}} -> min
    end) do
      {_, nil} -> nil
      {_, {_, mins}} -> mins
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day7Test do
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
        assert 15 == Day7.part2(@input |> String.split("\n", trim: true), _workers = 2, _base_seconds = 0)
      end

      describe "Workers" do
        test "work_till_next_done/1" do
          assert nil == Workers.new(2) |> Workers.work_till_next_done()

          workers = %{
            1 => {"C", 3},
            2 => nil,
          }
          assert {3, {["C"], %{1 => nil, 2 => nil}}} == Workers.work_till_next_done(workers)

          workers = %{
            1 => {"B", 2},
            2 => {"F", 5},
          }
          assert {2, {["B"], %{1 => nil, 2 => {"F", 3}}}} == Workers.work_till_next_done(workers)

          workers = %{
            1 => {"B", 2},
            2 => {"F", 5},
            3 => {"D", 2},
          }
          assert {2, {["D", "B"], %{1 => nil, 2 => {"F", 3}, 3 => nil}}} == Workers.work_till_next_done(workers)
        end

        test "assign_workers/1" do
          workers = %{
            1 => nil,
            2 => nil
          }
          assert {[], %{1 => {"A", 1}, 2 => {"B", 2}}} == Workers.assign_work(workers, [{"A", 1}, {"B", 2}])

          workers = %{
            1 => nil,
            2 => {"B", 2},
          }
          assert {[{"D", 4}], %{1 => {"C", 3}, 2 => {"B", 2}}} == Workers.assign_work(workers, [{"C", 3}, {"D", 4}])
        end
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
