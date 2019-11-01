defmodule Day21 do
  alias __MODULE__.Image

  def part1(input) do
    Image.new()
    |> Image.enhance(
      input |> parse_rules |> Image.enhancer(),
      5
    )
    |> Image.pixels()
  end

  def part2(input) do
    Image.new()
    |> Image.enhance(
      input |> parse_rules |> Image.enhancer(),
      18
    )
    |> Image.pixels()
  end

  defp parse_rules(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Enum.into(%{}, fn line ->
      [pattern, result] = String.split(line, " => ")
      {pattern, result}
    end)
  end

  defmodule Image do
    defstruct [:rows]

    @init_image """
    .#.
    ..#
    ###
    """
    def new(raw \\ @init_image) do
      rows =
        raw
        |> String.splitter("\n", trim: true)
        |> Enum.map(&to_charlist/1)

      %__MODULE__{rows: rows}
    end

    def size(%__MODULE__{rows: rows}), do: length(rows)

    def pixels(%__MODULE__{rows: rows}) do
      rows
      |> Stream.flat_map(& &1)
      |> Enum.count(& &1 == ?#)
    end

    def enhance(%__MODULE__{} = img, _fun, 0) do
      img
    end

    def enhance(%__MODULE__{} = img, fun, round) do
      img
      |> enhance(fun)
      |> enhance(fun, round - 1)
    end

    def enhance(%__MODULE__{} = img, fun) do
      case size(img) do
        2 -> fun.(img)
        3 -> fun.(img)
        size when rem(size, 2) == 0 -> img |> chunk_every(2) |> enhance(fun) |> unchunk()
        size when rem(size, 3) == 0 -> img |> chunk_every(3) |> enhance(fun) |> unchunk()
      end
    end

    def enhance([h | t], fun) do
      [enhance(h, fun) | enhance(t, fun)]
    end

    def enhance([], _) do
      []
    end

    def chunk_every(%__MODULE__{rows: rows}, n) do
      rows
      |> Stream.map(&Enum.chunk_every(&1, n))
      |> Stream.chunk_every(n)
      |> Enum.map(fn group ->
        group
        |> Stream.zip()
        |> Stream.map(&Tuple.to_list/1)
        |> Enum.map(fn rows -> %__MODULE__{rows: rows} end)
      end)
    end

    def unchunk(group_of_images) do
      rows =
        group_of_images
        |> Stream.map(fn group ->
          Enum.map(group, &Map.fetch!(&1, :rows))
        end)
        |> Enum.flat_map(fn group ->
          group
          |> Stream.zip()
          |> Stream.map(&Tuple.to_list/1)
          |> Enum.map(&Enum.concat/1)
        end)

      %__MODULE__{rows: rows}
    end

    def enhancer(rules) do
      fn %__MODULE__{} = image ->
        new_rows =
          image
          |> variants
          |> Enum.find_value(fn %__MODULE__{rows: rows} ->
            Map.get(rules, Enum.join(rows, "/"))
          end)
          |> String.splitter("/")
          |> Enum.map(&to_charlist/1)

        %{image | rows: new_rows}
      end
    end

    def variants(image) do
      0..3
      |> Stream.map(&rotate(image, &1))
      |> Stream.zip([:h, :v, :h, :v])
      |> Enum.flat_map(fn {img, v_or_h} ->
        [img, flip(img, v_or_h)]
      end)
    end

    def flip(%__MODULE__{rows: rows} = image, :v) do
      %{image | rows: Enum.reverse(rows)}
    end

    def flip(%__MODULE__{rows: rows} = image, :h) do
      %{image | rows: Enum.map(rows, &Enum.reverse(&1))}
    end

    def rotate(%__MODULE__{} = image, 0) do
      image
    end

    def rotate(%__MODULE__{rows: rows}, n) do
      new_rows =
        rows
        |> Enum.zip()
        |> Enum.map(fn row ->
          row |> Tuple.to_list() |> Enum.reverse()
        end)

      %__MODULE__{rows: new_rows}
      |> rotate(n - 1)
    end
  end
end

defimpl String.Chars, for: Day21.Image do
  def to_string(%{rows: rows}) do
    Enum.join(rows, "\n")
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day21Test do
      use ExUnit.Case
      alias Day21.Image

      @rules %{".#./..#/###" => "#..#/..../..../#..#", "../.#" => "##./#../..."}
      test "enhance" do
        img = Image.new()
        enhancer = Image.enhancer(@rules)

        assert Image.enhance(img, enhancer) |> to_string() ==
                 """
                 #..#
                 ....
                 ....
                 #..#
                 """
                 |> String.trim_trailing()

        assert Image.enhance(img, enhancer, 2) |> to_string() ==
                 """
                 ##.##.
                 #..#..
                 ......
                 ##.##.
                 #..#..
                 ......
                 """
                 |> String.trim_trailing()
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day21.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day21.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
