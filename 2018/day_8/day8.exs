defmodule Day8 do
  @doc """
  1. 从做到右依次扫描数字序列，同时准备一个栈用来记录期望从剩余序列中获取的数据类型，可能为两种情况：
      - {:node, n} #=> 接下来 2 个数字为新的节点头部，该节点之后还有 n-1 个节点
      - {:data, n} #=> 接下来 n 个数字为当前节点的 metadata entry
  2. 每次根据栈顶解析序列的下一个数据:
      a. {:node, n} #=> 当 n 为 0 时，将其移出栈，继续解析剩余序列；
        当 n 不为 0 时，将 n 更新为 n-1, 同时解析下一个头部，根据结果依次将以下新元素入栈： {:data, data_entry_num}, {:node, child_node_num}
      b. {:data, n} #=> 将其移出栈，取接下来 n 个数字累加计入结果统计。
  3. 栈初始为 [{:node, 1}]
  """
  def part1(nums) do
    calc_sum(nums, [{:node, 1}], 0)
  end

  @doc """
  1. 类似 part1 准备一个栈，扫描数字序列，得到两个 map(Hash) 分别记录每个 node 的 children 和 entries。
    细节变动：
      - {:node, n} 增加第三个元素——这些节点的 parent，即 {:node, n, parent}
      - {:data, n} 增加第三个元素——这些 data entires 属于的 node, 即 {:data, n, node}
      - 初始栈为 [{:node, 1, nil}], 起始 node 编号从 1 开始，每当发现一个新 node 该数加 1
  2. 得到两个分别记录每个 node 的 children 和 entries 后，按照规则计算出 root node 的 sum
  """
  def part2(nums) do
    Nodes.build({%{}, %{}}, nums, [{:node, 1, nil}], 1)
    |> Nodes.node_sum(1)
  end

  def calc_sum([], _, sum), do: sum
  def calc_sum(nums, [{:node, 0} | rest_stack], sum), do: calc_sum(nums, rest_stack, sum)

  def calc_sum([children_num, data_num | rest_nums], [{:node, n} | rest_stack], sum) do
    calc_sum(rest_nums, [{:node, children_num}, {:data, data_num}, {:node, n - 1} | rest_stack], sum)
  end

  def calc_sum(nums, [{:data, 0} | rest_stack], sum) do
    calc_sum(nums, rest_stack, sum)
  end

  def calc_sum([entry | rest_nums], [{:data, n} | rest_stack], sum) do
    calc_sum(rest_nums, [{:data, n - 1} | rest_stack], sum + entry)
  end
end

defmodule Nodes do
  def node_sum(nodes = {nodes_children, nodes_entries}, node) do
    case Map.get(nodes_children, node) do
      nil -> nodes_entries |> Map.fetch!(node) |> Enum.sum()
      children -> nodes_entries |> Map.fetch!(node) |> Enum.reduce(0, fn entry, sum ->
        sum + case Enum.at(children, -entry) do
          nil -> 0
          child -> node_sum(nodes, child)
        end
      end)
    end
  end

  def build(nodes, [], _, _), do: nodes
  def build(nodes, nums, [{:node, 0, _parent} | rest], new_node) do
    build(nodes, nums, rest, new_node)
  end

  def build({nodes_children, nodes_entries}, [children_num, data_num | rest_nums], [{:node, n, parent} | rest_stack], new_node) do
    build({update_nodes_child(nodes_children, parent, new_node), nodes_entries}, rest_nums, [{:node, children_num, new_node}, {:data, data_num, new_node}, {:node, n - 1, parent} | rest_stack], gen_next_new_node(new_node))
  end

  def build(nodes, nums, [{:data, 0, _node} | rest_stack], new_node) do
    build(nodes, nums, rest_stack, new_node)
  end

  def build({nodes_children, nodes_entries}, [entry | rest_nums], [{:data, n, node} | rest_stack], new_node) do
    build({nodes_children, update_nodes_entry(nodes_entries, node, entry)}, rest_nums, [{:data, n - 1, node} | rest_stack], new_node)
  end

  def update_nodes_child(nodes_children, parent, child) do
    nodes_children
    |> Map.update(parent, [child], &[child | &1])
  end

  def update_nodes_entry(nodes_entries, node, entry) do
    nodes_entries
    |> Map.update(node, [entry], &[entry | &1])
  end

  defp gen_next_new_node(node_num) do
    node_num + 1
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day8Test do
      use ExUnit.Case

      @input "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"
      test "part1" do
        assert 138 == Day8.part1(@input |> String.splitter(" ") |> Enum.map(&String.to_integer/1))
      end

      test "part2" do
        assert 66 == Day8.part2(@input |> String.splitter(" ") |> Enum.map(&String.to_integer/1))
      end
    end

  [input_file, "--part1"] ->
    input_file
    |> File.read!()
    |> String.splitter(" ")
    |> Enum.map(&String.to_integer/1)
    |> Day8.part1()
    |> IO.puts()

  [input_file, "--part2"] ->
    input_file
    |> File.read!()
    |> String.splitter(" ")
    |> Enum.map(&String.to_integer/1)
    |> Day8.part2()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "usage: [input_file] --flag")
end
