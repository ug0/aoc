defmodule Day9 do
  @doc """
  将问题分解为两部分：
  1. MarbleRing 构造一个环，并负责插入、删除、访问各节点的接口实现
  2. Game 处理游戏逻辑，逐回合进行直到使用完 last marble
      - players: 用于记录各玩家得分
      - current_marble: 当前 marble
      - marbles: 所有 marbles 的环的抽象，通过它进行对 marble 的数据访问和操作
      - next_turn: 下一回合（数字即为下一个 marble 的值)
      - next_player: 下一个玩家
      - final_turn: 最后一回合（即 last marble）
      - ended?: 游戏是否已经结束
  """
  def part1(input) do
    input
    |> parse_input()
    |> winning_score()
  end

  def part2(input) do
    {num_of_players, last_points} = parse_input(input)

    winning_score({num_of_players, last_points * 100})
  end

  def winning_score({num_of_players, last_points}) do
    Game.new(num_of_players, last_points)
    |> Game.play_till_end()
    |> Map.fetch!(:players)
    |> Enum.max_by(fn {_, score} -> score end)
    |> elem(1)
  end

  def parse_input(input) do
    [[players], [last_points]] = Regex.scan(~r/(\d+)/, input, capture: :all_but_first)

    {String.to_integer(players), String.to_integer(last_points)}
  end
end

defmodule Game do
  defstruct [:players, :current_marble, :marbles, :next_turn, :next_player, :final_turn, :ended?]

  def new(num_of_players, last_points) when num_of_players > 0 do
    {:ok, marbles} = MarbleRing.init()

    %Game{
      players: 1..num_of_players |> Enum.into(%{}, &{&1, 0}),
      current_marble: 0,
      next_player: 1,
      next_turn: 1,
      final_turn: last_points,
      ended?: false,
      marbles: marbles
    }
  end

  def play_till_end(game = %Game{ended?: true}), do: game
  def play_till_end(game = %Game{}) do
    game
    |> play_turn()
    |> play_till_end()
  end

  def play_turn(game = %Game{next_turn: turn, final_turn: final_turn}) when turn > final_turn do
    %Game{game | ended?: true}
  end

  def play_turn(
        game = %Game{
          current_marble: marble,
          marbles: marbles,
          next_turn: turn,
          next_player: player,
          players: players
        }
      ) when rem(turn, 23) == 0 do
    marble_to_delete = MarbleRing.previous_marble(marbles, marble, 7)
    players = Map.update!(players, player, &(&1 + turn + marble_to_delete))

    current_marble = MarbleRing.next_marble(marbles, marble_to_delete)
    MarbleRing.delete_marble(marbles, marble_to_delete)

    %Game{game | next_turn: turn + 1, next_player: next_player(game), current_marble: current_marble, players: players}
  end

  def play_turn(game = %Game{current_marble: marble, marbles: marbles, next_turn: turn}) do
    MarbleRing.insert_after(marbles, marble, 1, turn)

    %Game{game | current_marble: turn, next_turn: turn + 1, next_player: next_player(game)}
  end

  def end?(%Game{next_turn: next_turn, final_turn: final_turn}), do: next_turn > final_turn

  defp next_player(%Game{players: players, next_player: player}) when player == map_size(players), do: 1

  defp next_player(%Game{next_player: player}), do: player + 1
end

defmodule MarbleRing do
  def init() do
    marbles = :ets.new(__MODULE__, [:set, :protected])
    insert_new_marble(marbles, 0, 0, 0)
    {:ok, marbles}
  end

  def insert_after(marbles, marble, offset \\ 0, new_marble) do
    insert_right_after(marbles, next_marble(marbles, marble, offset), new_marble)
  end

  def insert_right_after(marbles, marble, new_marble) do
    insert_new_marble(marbles, new_marble, marble, next_marble(marbles, marble))
  end

  defp insert_new_marble(marbles, new_marble, previous, next) do
    set_new_previous_marble(marbles, next, new_marble)
    set_new_next_marble(marbles, previous, new_marble)

    true = :ets.insert_new(marbles, {new_marble, {previous, next}})
  end

  def delete_marble(marbles, marble) do
    previous = previous_marble(marbles, marble)
    next = next_marble(marbles, marble)

    set_new_previous_marble(marbles, next, previous)
    set_new_next_marble(marbles, previous, next)

    true = :ets.delete(marbles, marble)
  end

  def next_marble(marbles, marble, offset \\ 1)
  def next_marble(_marbles, marble, 0), do: marble
  def next_marble(marbles, marble, offset) when offset < 0, do: previous_marble(marbles, marble, -offset)

  def next_marble(marbles, marble, offset) when offset > 0 do
    [{^marble, {_previous, next}}] = :ets.lookup(marbles, marble)

    next_marble(marbles, next, offset - 1)
  end

  def previous_marble(marbles, marble, offset \\ 1)
  def previous_marble(_marbles, marble, 0), do: marble
  def previous_marble(marbles, marble, offset) when offset < 0, do: next_marble(marbles, marble, -offset)

  def previous_marble(marbles, marble, offset) when offset > 0 do
    [{^marble, {previous, _next}}] = :ets.lookup(marbles, marble)

    previous_marble(marbles, previous, offset - 1)
  end

  defp set_new_previous_marble(marbles, marble, new_previous) do
    case :ets.lookup(marbles, marble) do
      [] -> false
      [{^marble, {_previous, next}}] -> :ets.insert(marbles, {marble, {new_previous, next}})
    end
  end

  defp set_new_next_marble(marbles, marble, new_next) do
    case :ets.lookup(marbles, marble) do
      [] -> false
      [{^marble, {previous, _next}}] -> :ets.insert(marbles, {marble, {previous, new_next}})
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day9Test do
      use ExUnit.Case

      test "part1 result" do
        [
          {10, 1618, 8317},
          {13, 7999, 146_373},
          {17, 1104, 2764},
          {21, 6111, 54718},
          {30, 5807, 37305}
        ]
        |> Enum.each(fn {players, last_points, winning_score} ->
          assert winning_score == Day9.winning_score({players, last_points})
        end)
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day9.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day9.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
