defmodule Cart do
  defstruct [:location, :direction, :turning_queue, :ticks]

  def new(symbol, location) do
    %Cart{
      location: location,
      direction: parse_direction(symbol),
      turning_queue: init_turning_queue(),
      ticks: 0
    }
  end

  def crash?(%Cart{location: {x, y}}, %Cart{location: {x, y}}), do: true
  def crash?(_, _), do: false

  def move(cart = %Cart{direction: direction, location: {x, y}, ticks: ticks}) do
    case direction do
      :up -> %Cart{cart | location: {x, y - 1}, ticks: ticks + 1}
      :down -> %Cart{cart | location: {x, y + 1}, ticks: ticks + 1}
      :left -> %Cart{cart | location: {x - 1, y}, ticks: ticks + 1}
      :right -> %Cart{cart | location: {x + 1, y}, ticks: ticks + 1}
    end
  end

  def arrive_at(cart = %Cart{}, track) when track in '-|', do: cart

  def arrive_at(cart = %Cart{direction: direction}, ?/) do
    case direction do
      :up -> turn(cart, :right)
      :left -> turn(cart, :left)
      :right -> turn(cart, :left)
      :down -> turn(cart, :right)
    end
  end

  def arrive_at(cart = %Cart{direction: direction}, ?\\) do
    case direction do
      :up -> turn(cart, :left)
      :left -> turn(cart, :right)
      :right -> turn(cart, :right)
      :down -> turn(cart, :left)
    end
  end

  def arrive_at(cart, ?+), do: arrive_at_intersection(cart)

  def arrive_at_intersection(%Cart{turning_queue: queue} = cart) do
    {{:value, turning_direction}, rest_queue} = :queue.out(queue)

    %Cart{cart | turning_queue: :queue.in(turning_direction, rest_queue)}
    |> turn(turning_direction)
  end

  def turn(%Cart{direction: direction} = cart, :left) do
    %Cart{cart | direction: direction_after_turn_left(direction)}
  end

  def turn(%Cart{direction: direction} = cart, :right) do
    %Cart{cart | direction: direction_after_turn_right(direction)}
  end

  def turn(%Cart{} = cart, :straight), do: cart

  def symbol(%Cart{direction: direction}) do
    case direction do
      :up -> ?^
      :down -> ?v
      :left -> ?<
      :right -> ?>
    end
  end

  defp direction_after_turn_left(direction),
    do: next_direction([:up, :left, :down, :right, :up], direction)

  defp direction_after_turn_right(direction),
    do: next_direction([:up, :right, :down, :left, :up], direction)

  defp next_direction([direction, next | _], direction), do: next
  defp next_direction([_ | rest], direction), do: next_direction(rest, direction)

  defp init_turning_queue do
    q = :queue.new()
    q = :queue.in(:left, q)
    q = :queue.in(:straight, q)
    q = :queue.in(:right, q)
    q
  end

  defp parse_direction(symbol) do
    case symbol do
      ?^ -> :up
      ?< -> :left
      ?> -> :right
      ?v -> :down
    end
  end
end

defmodule Day13 do
  def part1(input) do
    {tracks, carts} = parse_input(input)
    carts_queue = make_carts_queue(carts, fn {_, cart} -> cart end)

    ticking(tracks, carts_queue, fn moved_cart, rest_queue ->
      if rest_queue |> :queue.to_list() |> Enum.any?(&Cart.crash?(moved_cart, &1)) do
        {:halt, moved_cart.location}
      else
        {:cont, :queue.in(moved_cart, rest_queue)}
      end
    end)
  end

  def part2(input) do
    {tracks, carts} = parse_input(input)
    carts_queue = make_carts_queue(carts, fn {_, cart} -> cart end)

    ticking(tracks, carts_queue, fn moved_cart, rest_queue ->
      rest_length = :queue.len(rest_queue)

      survived = :queue.filter(&(!Cart.crash?(&1, moved_cart)), rest_queue)

      case :queue.len(survived) do
        1 ->
          current_ticks = moved_cart.ticks

          {:halt,
           case :queue.out(survived) do
             {{:value, %Cart{ticks: ^current_ticks, location: location}}, _} -> location
             {{:value, cart}, _} -> Cart.move(cart).location
           end}

        ^rest_length ->
          {:cont, :queue.in(moved_cart, survived)}

        _ ->
          {:cont, survived}
      end
    end)
  end

  def ticking(tracks, carts_queue, ticks \\ 1, fun) do
    case :queue.out(carts_queue) do
      {:empty, _} ->
        {:error, :no_carts}

      {{:value, %Cart{ticks: ^ticks}}, _rest} ->
        next_carts_queue =
          carts_queue
          |> :queue.to_list()
          |> make_carts_queue()

        ticking(tracks, next_carts_queue, ticks + 1, fun)

      {{:value, %Cart{} = cart}, rest} ->
        moved_cart = Cart.move(cart)
        moved_cart = moved_cart |> Cart.arrive_at(Map.fetch!(tracks, moved_cart.location))

        # uncomment below if you want to watch the process on the screen
        # display(tracks, [moved_cart | :queue.to_list(rest)])
        # :timer.sleep(500)
        # IO.puts("\n")

        case fun.(moved_cart, rest) do
          {:cont, new_carts_queue} -> ticking(tracks, new_carts_queue, ticks, fun)
          {:halt, result} -> result
        end
    end
  end

  defp make_carts_queue(carts_list, fun \\ & &1) do
    carts_list
    |> Stream.map(fun)
    |> Enum.sort_by(fn %Cart{location: {x, y}} -> {y, x} end)
    |> Enum.reduce(:queue.new(), fn cart, queue ->
      :queue.in(cart, queue)
    end)
  end

  # For debugging and fun
  def display(tracks, carts) do
    {right, bottom} =
      tracks
      |> Map.keys()
      |> Enum.reduce({0, 0}, fn {x, y}, {max_x, max_y} ->
        {max(x, max_x), max(y, max_y)}
      end)

    0..bottom
    |> Enum.each(fn y ->
      0..right
      |> Stream.map(fn x ->
        case Enum.find(carts, fn %Cart{location: {c_x, c_y}} -> c_x == x && c_y == y end) do
          nil -> Map.get(tracks, {x, y})
          cart -> Cart.symbol(cart)
        end
      end)
      |> Enum.reject(&(&1 == nil))
      |> List.to_string()
      |> IO.puts()
    end)
  end

  defp parse_input(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.with_index()
    |> Enum.reduce({%{}, %{}}, fn {line, y}, acc ->
      line
      |> String.to_charlist()
      |> Stream.with_index()
      |> Enum.reduce(acc, fn
        {symbol, x}, {tracks, carts} when symbol in '<>' ->
          {Map.put(tracks, {x, y}, ?-), Map.put(carts, map_size(carts), Cart.new(symbol, {x, y}))}

        {symbol, x}, {tracks, carts} when symbol in '^v' ->
          {Map.put(tracks, {x, y}, ?|), Map.put(carts, map_size(carts), Cart.new(symbol, {x, y}))}

        {symbol, x}, {tracks, carts} ->
          {Map.put(tracks, {x, y}, symbol), carts}
      end)
    end)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day13Test do
      use ExUnit.Case

      @input """
      /->-\\
      |   |  /----\\
      | /-+--+-\\  |
      | | |  | v  |
      \\-+-/  \\-+--/
        \\------/
      """
      test "part 1 result" do
        assert {7, 3} == Day13.part1(@input)
      end

      @input """
      />-<\\
      |   |
      | /<+-\\
      | | | v
      \\>+</ |
        |   ^
        \\<->/
      """
      test "part 2 result" do
        assert {6, 4} == Day13.part2(@input)
      end

      describe "Cart" do
        test "init new cart" do
          assert %Cart{direction: :up, location: {0, 0}} = Cart.new(?^, {0, 0})
        end

        test "new direction after turning" do
          cart = Cart.new(?^, {0, 0})
          assert %Cart{direction: :left} = Cart.turn(cart, :left)
          assert %Cart{direction: :right} = Cart.turn(cart, :right)
          assert cart == Cart.turn(cart, :straight)
        end

        test "move one step" do
          cart = Cart.new(?^, {0, 0})
          assert %Cart{location: {0, -1}, ticks: 1} = Cart.move(cart)

          cart = Cart.new(?<, {0, 0})
          assert %Cart{location: {-1, 0}} = Cart.move(cart)

          cart = Cart.new(?>, {0, 0})
          assert %Cart{location: {1, 0}} = Cart.move(cart)

          cart = Cart.new(?v, {0, 0})
          assert %Cart{location: {0, 1}} = Cart.move(cart)
        end

        test "arrive at intersection" do
          cart = Cart.new(?^, {0, 0})

          assert cart = %Cart{direction: :left} = Cart.arrive_at(cart, ?+)
          assert cart = %Cart{direction: :left} = Cart.arrive_at(cart, ?+)
          assert cart = %Cart{direction: :up} = Cart.arrive_at(cart, ?+)
        end

        test "arrive at curves" do
          cart = Cart.new(?^, {0, 0})

          assert cart = %Cart{direction: :right} = Cart.arrive_at(cart, ?/)
          assert cart = %Cart{direction: :down} = Cart.arrive_at(cart, ?\\)
          assert cart = %Cart{direction: :left} = Cart.arrive_at(cart, ?/)
          assert cart = %Cart{direction: :up} = Cart.arrive_at(cart, ?\\)
        end

        test "carts crash" do
          assert Cart.crash?(Cart.new(?^, {0, 0}), Cart.new(?>, {0, 0}))
          refute Cart.crash?(Cart.new(?^, {0, 0}), Cart.new(?>, {0, 1}))
        end
      end
    end

  [input, "--part1"] ->
    input
    |> File.read!()
    |> Day13.part1()
    |> IO.inspect()

  [input, "--part2"] ->
    input
    |> File.read!()
    |> Day13.part2()
    |> IO.inspect()

  _ ->
    IO.puts(:stderr, "usage: [input_file]")
end
