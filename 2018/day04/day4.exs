defmodule Guard do
  defstruct id: nil,
            asleep: false,
            sleep_min_counts: %{},
            frequent_sleep_min: {nil, 0},
            total_sleep_mins: 0,
            updated_at: nil

  def new(id, datetime) do
    %Guard{id: id, updated_at: datetime}
  end

  def update(
        guard = %Guard{
          asleep: true,
          total_sleep_mins: mins,
          sleep_min_counts: min_counts,
          updated_at: last_modified_at
        },
        {updated_at, {:wake, _}}
      ) do
    added_sleep_mins = div(NaiveDateTime.diff(updated_at, last_modified_at), 60)

    new_min_counts =
      last_modified_at.minute..(last_modified_at.minute + added_sleep_mins - 1)
      |> Enum.reduce(min_counts, fn m, acc ->
        Map.update(acc, rem(m, 60), 1, &(&1 + 1))
      end)

    %Guard{
      guard
      | asleep: false,
        sleep_min_counts: new_min_counts,
        updated_at: updated_at,
        frequent_sleep_min: new_min_counts |> Enum.max_by(fn {_, cnt} -> cnt end),
        total_sleep_mins: mins + added_sleep_mins
    }
  end

  def update(guard = %Guard{asleep: false}, {updated_at, {:sleep, _}}) do
    %Guard{guard | asleep: true, updated_at: updated_at}
  end

  def update(guard = %Guard{}, {updated_at, {_, _}}) do
    %Guard{guard | updated_at: updated_at}
  end
end

defmodule Day4 do
  @doc """
  扫描排序后的记录，以 guard ID 为键值记录每个 guard 信息：
    - 是否处于睡眠状态 asleep :: boolean
    - 各分钟睡眠次数 sleep_min_counts :: map
    - 最频繁睡眠时刻分钟 frequent_sleep_min :: {minute, count}
    - 总共睡眠分钟数 total_sleep_mins
    - 上次更新时间 updated_at
  最后筛选出最长睡眠时间的 Guard
  """
  def part1_result(input_stream) do
    guard =
      input_stream
      |> parse_logs
      |> Map.values()
      |> Enum.max_by(& &1.total_sleep_mins)

    most_sleep_minute =
      guard.sleep_min_counts
      |> Enum.max_by(fn {_, cnt} -> cnt end)
      |> elem(0)

    (guard.id |> String.to_integer()) * most_sleep_minute
  end

  @doc """
  利用 part1 扫描排序后的记录, 筛选出睡眠最频繁的 Guard
  """
  def part2_result(input_stream) do
    guard =
      input_stream
      |> parse_logs
      |> Map.values()
      |> Enum.max_by(fn %Guard{frequent_sleep_min: {_min, cnt}} -> cnt end)

    (guard.id |> String.to_integer()) * (guard.frequent_sleep_min |> elem(0))
  end

  def parse_logs(input_stream) do
    input_stream
    |> Enum.reduce({_current_guard_id = nil, _guards = %{}}, fn line, {current_guard, guards} ->
      case parse_line(line, current_guard) do
        {updated_at, {event, new_guard_id}} ->
          {new_guard_id,
           Map.update(guards, new_guard_id, Guard.new(new_guard_id, updated_at), fn old_guard ->
             Guard.update(old_guard, {updated_at, {event, new_guard_id}})
           end)}
      end
    end)
    |> elem(1)
  end

  def parse_line(line, current_guard) do
    {parse_datetime(line), parse_event(line, current_guard)}
  end

  def parse_datetime(str) do
    case Regex.scan(~r/^\[(.+)]/, str, capture: :all_but_first) do
      [[t_str]] -> NaiveDateTime.from_iso8601!("#{t_str}:00")
    end
  end

  def parse_event(str, current_guard) do
    case Regex.scan(~r/^\[.+\]\s(?:Guard\s#(\d+)\s)?(.+)$/, str, capture: :all_but_first) do
      [["", "falls asleep"]] -> {:sleep, current_guard}
      [["", "wakes up"]] -> {:wake, current_guard}
      [[new_guard, "begins shift"]] -> {:shift, new_guard}
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day4Test do
      use ExUnit.Case

      describe "parse_line/1" do
        test "parse one line" do
          assert {~N[1518-11-02 00:40:00], {:shift, "10"}} ==
                   Day4.parse_line(
                     "[1518-11-02 00:40] Guard #10 begins shift",
                     _current_guard = nil
                   )
        end
      end

      @input """
      [1518-11-01 00:00] Guard #10 begins shift
      [1518-11-01 00:05] falls asleep
      [1518-11-01 00:25] wakes up
      [1518-11-01 00:30] falls asleep
      [1518-11-01 00:55] wakes up
      [1518-11-01 23:58] Guard #99 begins shift
      [1518-11-02 00:40] falls asleep
      [1518-11-02 00:50] wakes up
      [1518-11-03 00:05] Guard #10 begins shift
      [1518-11-03 00:24] falls asleep
      [1518-11-03 00:29] wakes up
      [1518-11-04 00:02] Guard #99 begins shift
      [1518-11-04 00:36] falls asleep
      [1518-11-04 00:46] wakes up
      [1518-11-05 00:03] Guard #99 begins shift
      [1518-11-05 00:45] falls asleep
      [1518-11-05 00:55] wakes up
      """
      describe "part1_result/1" do
        test "test Day4 part 1" do
          assert 240 == Day4.part1_result(String.split(@input, "\n", trim: true))
        end
      end

      describe "part2_result/1" do
        test "test Day4 part 2" do
          assert 4455 == Day4.part2_result(String.split(@input, "\n", trim: true))
        end
      end

      describe "parse_datetime/1" do
        test "parse datetime" do
          assert ~N[1518-11-02 00:40:00] ==
                   Day4.parse_datetime("[1518-11-02 00:40] Guard #10 begins shift")
        end
      end

      describe "parse_event/2" do
        test "parse shift event" do
          assert {:shift, "10"} ==
                   Day4.parse_event(
                     "[1518-11-02 00:40] Guard #10 begins shift",
                     _current_guard = "99"
                   )
        end

        test "parse asleep event" do
          assert {:sleep, "99"} ==
                   Day4.parse_event(
                     "[1518-11-02 00:40] falls asleep",
                     _current_guard = "99"
                   )
        end

        test "parse awake event" do
          assert {:wake, "10"} ==
                   Day4.parse_event(
                     "[1518-11-04 00:46] wakes up",
                     _current_guard = "10"
                   )
        end
      end
    end

  [input_file] ->
    input_file
    |> File.stream!()
    |> Enum.sort()
    |> Day4.part2_result()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "wrong usage")
end
