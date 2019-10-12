defmodule Day16 do
  alias __MODULE__.Programs

  @initial_programs "abcdefghijklmnop"
  def part1(input, init \\ @initial_programs) do
    Programs.dance(init, parse_input(input))
  end

  @total_times 1_000_000
  def part2(input, init \\ @initial_programs) do
    moves = parse_input(input)

    Enum.reduce_while(1..@total_times, {init, %{init => 0}}, fn times, {programs, trace} ->
      new_programs = Programs.dance(programs, moves)

      case trace do
        %{^new_programs => prev} ->
          offset = rem(@total_times - times, times - prev)
          {p, _} = Enum.find(trace, fn {_, t} -> t == prev + offset end)
          {:halt, p}

        _ ->
          {:cont, {new_programs, Map.put(trace, new_programs, times)}}
      end
    end)
  end

  def parse_input(input) do
    String.split(input, ",", trim: true)
  end

  defmodule Programs do
    def dance(programs, moves) do
      Enum.reduce(moves, programs, fn move, acc ->
        dance_move(acc, move)
      end)
    end

    def dance_move(programs, <<kind::utf8, args::binary>>) do
      dance_move(programs, kind, parse_args(args))
    end

    def dance_move(programs, ?s, [n]) do
      {left, right} = String.split_at(programs, -n)
      right <> left
    end

    def dance_move(programs, ?x, [i, j]) do
      list = to_charlist(programs)

      list
      |> List.replace_at(i, Enum.at(list, j))
      |> List.replace_at(j, Enum.at(list, i))
      |> to_string()
    end

    def dance_move(programs, ?p, [x, y]) do
      String.replace(programs, [x, y], fn
        ^x -> y
        ^y -> x
      end)
    end

    defp parse_args(args_str) do
      args_str
      |> String.splitter("/")
      |> Enum.map(fn x ->
        case Integer.parse(x) do
          {n, _} -> n
          :error -> x
        end
      end)
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day16Test do
      use ExUnit.Case

      @input "s1,x3/4,pe/b"
      test "part1 result" do
        assert Day16.part1(@input, "abcde") == "baedc"
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day16.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day16.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
