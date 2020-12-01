defmodule Day5 do
  def part1(input) do
    Solution2.part1(input)
  end

  def part2(input) do
    Solution2.part2(input)
  end
end

defmodule Solution2 do
  @doc """
  O(n)
  准备一个空栈，从左至右一次一个字符扫描字符串。每获取一个字符按以下规则处理：
  1. 若栈为空，直接入栈，继续扫描剩下字符串。
  2. 若栈不为空，比较栈顶字符于当前扫描字符。若符合删除规则，栈顶字符出栈，继续扫描剩余字符串；若不符合规则，当前扫描字符串入栈，继续扫描剩余字符串。
  """
  def part1(input) do
    input
    |> scan([])
    |> length()
  end

  @doc """
  利用 part1 方法化简字符串，将结果分别移除每种字母(a-z)再对结果化简，取各字符串长度最小值
  """
  @a_to_z ?a..?z |> Enum.into([]) |> to_string() |> String.graphemes()
  def part2(input) do
    simplest_string = scan(input, []) |> to_string()

    @a_to_z
    |> Stream.map(fn letter ->
      simplest_string
      |> String.replace(Regex.compile!(letter, "i"), "")
      |> part1()
    end)
    |> Enum.min()
  end

  def scan("", stack), do: stack
  def scan(<<next, rest::binary>>, []), do: scan(rest, [next])

  def scan(<<next, rest::binary>>, [h | t] = stack) do
    cond do
      should_react?(h, next) -> scan(rest, t)
      true -> scan(rest, [next | stack])
    end
  end

  def should_react?(x, y) do
    abs(x - y) == 32
  end
end

defmodule Solution1 do
  @doc """
  O(n^2)
  递归使用正则表达式删除匹配字符(aA, Aa, ...)，直到字符串不再改变
  """
  def part1(input) do
    input
    |> remove_pairs()
    |> String.length()
  end

  @letters ?a..?z
           |> Enum.into([])
           |> to_string()
           |> String.split("", trim: true)

  @regex @letters
         |> Enum.flat_map(fn letter ->
           upper_letter = String.upcase(letter)
           [upper_letter <> letter, letter <> upper_letter]
         end)
         |> Enum.join("|")
         |> Regex.compile!()

  def remove_pairs(input) do
    case Regex.replace(@regex, input, "") do
      ^input -> input
      next_input -> remove_pairs(next_input)
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day5Test do
      use ExUnit.Case

      test "part1 result" do
        assert 0 == Day5.part1("aA")
        assert 0 == Day5.part1("abBA")
        assert 4 == Day5.part1("abAB")
        assert 6 == Day5.part1("aabAAB")
        assert 10 == Day5.part1("dabAcCaCBAcCcaDA")
      end

      test "part 2 result" do
        assert 4 == Day5.part2("dabAcCaCBAcCcaDA")
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> Day5.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> Day5.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
