Code.load_file("../intcode_program.exs", __DIR__)

defmodule Day13 do
  alias __MODULE__.Game

  def part1(input) do
    game = Game.start(input)

    send(game, {:get_grid, self()})

    receive do
      {:grid, grid} ->
        grid
        |> Stream.filter(fn {_, id} -> id == 2 end)
        |> Enum.count()
    end
  end

  def part2(input) do
    game =
      input
      |> String.replace(~r/[^,]+,/, "2,", global: false)
      |> Game.start()

    send(game, {:get_score, self()})

    receive do
      {:score, score} -> score
    end
  end

  defmodule Game do
    alias IntcodeProgram, as: Program

    def start(program) do
      game_device =
        spawn_link(__MODULE__, :game_device_fun, [%{grid: %{}, received_output: [], score: 0}])

      program
      |> Program.new(game_device, game_device)
      |> Program.execute()

      game_device
    end

    def game_device_fun(%{received_output: [score, 0, -1]} = state) do
      state
      |> update_score(score)
      |> clear_received_output()
      |> game_device_fun()
    end

    def game_device_fun(%{received_output: [id, y, x]} = state) do
      state
      |> draw_tile({x, y}, id)
      |> clear_received_output()
      |> game_device_fun()
    end

    def game_device_fun(state) do
      receive do
        {:write_output, value} ->
          state
          |> Map.update!(:received_output, &[value | &1])
          |> game_device_fun()

        {:read_input, pid} ->
          state
          |> move_joystick(pid)
          |> game_device_fun()

        {:get_grid, pid} ->
          send(pid, {:grid, state.grid})

        {:get_score, pid} ->
          send(pid, {:score, state.score})
      end
    end

    defp clear_received_output(state) do
      Map.put(state, :received_output, [])
    end

    defp draw_tile(state, position, id) do
      put_in(state, [:grid, position], id)
    end

    defp update_score(state, score) do
      Map.put(state, :score, score)
    end

    defp move_joystick(state, remote) do
      ## Uncomment below to watch the process
      # display_screen(state)
      # Process.sleep(100)

      case {ball_position(state), paddle_position(state)} do
        {{x, _}, {x, _}} -> send(remote, 0)
        {{x1, _}, {x2, _}} when x1 > x2 -> send(remote, 1)
        _ -> send(remote, -1)
      end

      state
    end

    defp ball_position(%{grid: grid}) do
      grid
      |> Enum.find(fn {_, object} -> object == 4 end)
      |> elem(0)
    end

    defp paddle_position(%{grid: grid}) do
      grid
      |> Enum.find(fn {_, object} -> object == 3 end)
      |> elem(0)
    end

    # show the playing process
    defp display_screen(%{grid: grid, score: score} = state) do
      points = Map.keys(grid)
      {max_x, _} = Enum.max_by(points, fn {x, _} -> x end)
      {_, max_y} = Enum.max_by(points, fn {_, y} -> y end)

      0..max_y
      |> Enum.each(fn y ->
        0..max_x
        |> Enum.map(fn x ->
          case Map.get(grid, {x, y}) do
            0 -> ?\s
            1 -> ?#
            2 -> ?B
            3 -> ?=
            4 -> ?o
            _ -> ?\s
          end
        end)
        |> IO.puts()
      end)

      IO.puts("Score: #{score}")

      state
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day13Test do
      use ExUnit.Case
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day13.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day13.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
