defmodule Day12 do
  alias __MODULE__.Moon

  def part1(input, steps \\ 1000) do
    moons = input |> parse_moons()

    pass_time_steps(moons, steps)

    moons
    |> Stream.map(&Moon.energy/1)
    |> Enum.sum()
  end

  # all three dimensions repeat the initial state
  def part2(input) do
    moons = input |> parse_moons()

    _dimensions =
      0..2
      |> Enum.map(fn dimension ->
        compare_fun = build_compare_fun(dimension)
        initial_state = compare_fun.(moons)

        Stream.repeatedly(fn ->
          pass_one_time_step(moons)
          compare_fun.(moons)
        end)
        |> Stream.with_index(1)
        |> Enum.find(fn {state, _index} -> state == initial_state end)
        |> elem(1)
      end)
      |> lcm()
  end

  defp lcm([n | []]), do: n
  defp lcm([h | t]), do: lcm(h, lcm(t))
  defp lcm(a, b), do: (a * b / Integer.gcd(a, b)) |> round()

  defp build_compare_fun(dimension) do
    fn moons ->
      Enum.map(
        moons,
        fn moon ->
          %{position: pos, velocity: vel} = Moon.state(moon)
          [pos, vel] |> Enum.map(&Enum.at(&1, dimension))
        end
      )
    end
  end

  defp pass_time_steps(moons, 0) do
    moons
  end

  defp pass_time_steps(moons, steps) do
    moons
    |> pass_one_time_step()
    |> pass_time_steps(steps - 1)
  end

  defp pass_one_time_step(moons) do
    moons
    |> pair_combinations()
    |> Enum.each(fn {moon1, moon2} ->
      Moon.apply_gravity(moon1, moon2)
    end)

    moons
    |> Enum.each(&Moon.apply_velocity/1)

    moons
  end

  def pair_combinations([]) do
    []
  end

  def pair_combinations([first | rest]) do
    Enum.map(rest, &{first, &1}) ++ pair_combinations(rest)
  end

  defp parse_moons(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(fn line ->
      line
      |> String.replace(~r/[^\d-,]+/, "")
      |> String.splitter(",")
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(fn position ->
      {:ok, moon} = Moon.new(position)
      moon
    end)
  end

  defmodule Moon do
    def new(position, velocity \\ [0, 0, 0]) do
      Agent.start_link(fn ->
        %{
          position: position,
          velocity: velocity
        }
      end)
    end

    def state(moon) do
      Agent.get(moon, & &1)
    end

    def position(moon) do
      Agent.get(moon, fn %{position: position} -> position end)
    end

    def energy(moon) do
      Agent.get(moon, fn %{position: v_pos, velocity: v_vol} ->
        [v_pos, v_vol]
        |> Stream.map(fn vector ->
          vector
          |> Stream.map(&abs/1)
          |> Enum.reduce(&Kernel.+/2)
        end)
        |> Enum.reduce(&Kernel.*/2)
      end)
    end

    def apply_gravity(moon1, moon2) do
      {change1, change2} = calc_velocity_changes(position(moon1), position(moon2))

      [
        {moon1, change1},
        {moon2, change2}
      ]
      |> Enum.each(fn {moon, change} ->
        Agent.update(moon, fn state ->
          Map.update!(state, :velocity, &vec_add(&1, change))
        end)
      end)
    end

    def apply_velocity(moon) do
      Agent.update(moon, fn state ->
        Map.update!(state, :position, &vec_add(&1, state.velocity))
      end)
    end

    defp calc_velocity_changes(position1, position2) do
      position1
      |> Stream.zip(position2)
      |> Stream.map(fn
        {x, x} -> {0, 0}
        {x, y} when x > y -> {-1, 1}
        _ -> {1, -1}
      end)
      |> Enum.unzip()
    end

    defp vec_add(v1, v2) do
      v1
      |> Stream.zip(v2)
      |> Enum.map(fn {a, b} -> a + b end)
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day12Test do
      use ExUnit.Case

      test "part1" do
        assert Day12.part1(
                 """
                 <x=-1, y=0, z=2>
                 <x=2, y=-10, z=-7>
                 <x=4, y=-8, z=8>
                 <x=3, y=5, z=-1>
                 """,
                 10
               ) == 179

        assert Day12.part1(
                 """
                 <x=-8, y=-10, z=0>
                 <x=5, y=5, z=10>
                 <x=2, y=-7, z=3>
                 <x=9, y=-8, z=-3>
                 """,
                 100
               ) == 1940
      end

      test "part2" do
        assert Day12.part2("""
               <x=-1, y=0, z=2>
               <x=2, y=-10, z=-7>
               <x=4, y=-8, z=8>
               <x=3, y=5, z=-1>
               """) == 2772
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day12.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.trim_trailing()
    |> Day12.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
