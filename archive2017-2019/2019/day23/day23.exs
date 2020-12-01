Code.load_file("../intcode_program.exs", __DIR__)

defmodule Day23 do
  alias __MODULE__.{Computer, Router}

  def part1(program) do
    Router.start()
    Router.register(255, self())

    0..49
    |> Enum.map(&Computer.new(program, &1))
    |> Enum.map(&Computer.start/1)

    receive do
      {:packet, {_x, y}} -> y
    end
  end

  def part2(program) do
    Router.start(%{nat: self()})
    Router.register(255, self())

    0..49
    |> Enum.map(&Computer.new(program, &1))
    |> Enum.map(&Computer.start/1)

    run_nat(nil, nil)
  end

  defp run_nat(packet, sent) do
    receive do
      {:packet, packet} -> run_nat(packet, sent)
      {:monitor, _} -> run_nat(packet, sent)
    after
      100 ->
        if packet == sent do
          elem(packet, 1)
        else
          Router.forward(0, {:packet, packet})
          run_nat(packet, packet)
        end
    end
  end

  defmodule Router do
    use GenServer

    def start(initial_table \\ %{}) do
      GenServer.start_link(__MODULE__, initial_table, name: Router)
    end

    def init(initial_table) do
      {:ok, initial_table}
    end

    def register(address, pid) do
      GenServer.cast(Router, {:register, address, pid})
    end

    def forward(address, data) do
      GenServer.cast(Router, {:forward_packet, address, data})
    end

    def handle_cast({:register, address, pid}, address_table) do
      {:noreply, Map.put(address_table, address, pid)}
    end

    def handle_cast({:forward_packet, address, data}, address_table) do
      # not really need to monitor all packets delivering
      case address_table do
        %{:nat => nat, ^address => pid} when nat != pid ->
          send(pid, data)
          send(nat, {:monitor, address, data})

        %{^address => pid} ->
          send(pid, data)
      end

      {:noreply, address_table}
    end
  end

  defmodule Computer do
    alias Day23.Router
    alias IntcodeProgram, as: Program

    def new(program, address) do
      process = spawn_link(__MODULE__, :run, [:req_address, address])
      Router.register(address, process)

      program
      |> Program.new(process, process)
    end

    def start(computer) do
      Task.start_link(fn -> Program.execute(computer) end)
    end

    def run(:req_address, address) do
      receive do
        {:read_input, pid} ->
          send(pid, address)
          run(:ready, :queue.new(), [])
      end
    end

    def run(:ready, packets_queue, _packet = [y, x, address]) do
      send_packet(address, {x, y})
      run(:ready, packets_queue, [])
    end

    def run(:ready, packets_queue, partial_packet) do
      receive do
        {:read_input, pid} ->
          case :queue.out(packets_queue) do
            {:empty, _} ->
              send(pid, -1)
              run(:ready, packets_queue, partial_packet)

            {{:value, {x, y}}, rest} ->
              send(pid, x)
              run(:ready, :queue.in_r({y}, rest), partial_packet)

            {{:value, {y}}, rest} ->
              send(pid, y)
              run(:ready, rest, partial_packet)
          end

        {:write_output, value} ->
          run(:ready, packets_queue, [value | partial_packet])

        {:packet, packet} ->
          run(:ready, :queue.in(packet, packets_queue), partial_packet)
      end
    end

    defp send_packet(address, packet) do
      Router.forward(address, {:packet, packet})
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day23Test do
      use ExUnit.Case
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day23.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day23.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
