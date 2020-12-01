defmodule Message do
  defstruct [:points, :bounds]

  def build_from_lines(lines) do
    points = lines
    |> Enum.map(&parse_line/1)

    %Message{points: points, bounds: parse_bounds(points)}
  end

  def process(message = %Message{bounds: {top, right, bottom, left}}, passed_seconds \\ 0) do
    scale = bottom - top + right - left

    if scale < 100 do
      :timer.sleep(100)
      IO.puts("passed seconds: #{passed_seconds}")
      display(message)
    end

    message
    |> transfer(1)
    |> process(passed_seconds + 1)
  end

  def display(%Message{points: points, bounds: {top, right, bottom, left}}) do
    Enum.each(top..bottom, fn y ->
      Stream.map(left..right, fn x ->
        if has_point?(points, {x, y}) do
          "#"
        else
          "."
        end
      end)
      |> Enum.join("")
      |> IO.puts()
    end)

    IO.puts("\n")
  end

  def transfer(message = %{points: points}, n \\ 1) do
    new_points = Enum.map(points, fn {{x, y}, {vx, vy}} -> {{x + vx * n, y + vy * n}, {vx, vy}} end)
    %Message{message | points: new_points, bounds: parse_bounds(new_points)}
  end

  defp has_point?(points, point) do
    Enum.any?(points, fn {another_point, _} -> another_point == point end)
  end

  defp parse_bounds([{{x, y}, _} | rest]), do: parse_bounds(rest, {y, x, y, x})
  defp parse_bounds([], bounds) when is_tuple(bounds), do: bounds
  defp parse_bounds([{{x, y}, _} | rest], {top, right, bottom, left}) do
    parse_bounds(rest, {min(y, top), max(x, right), max(y, bottom), min(x, left)})
  end

  defp parse_line(line) do
    [[x], [y], [vx], [vy]] = Regex.scan(~r/(-?\d+)/, line, capture: :all_but_first)
    {{String.to_integer(x), String.to_integer(y)}, {String.to_integer(vx), String.to_integer(vy)}}
  end
end

case System.argv() do

  [input_file] ->
    input_file
    |> File.stream!()
    |> Message.build_from_lines()
    |> Message.process()

  _ ->
    IO.puts(:stderr, "usage: [input_file]")
end
