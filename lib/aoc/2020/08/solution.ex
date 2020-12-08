defmodule Aoc.Y2020.D08 do
  use Aoc.Input

  defmodule Program do
    defstruct [:instructions, :acc, :pointer, :terminated]

    def new(instructions) do
      %__MODULE__{
        instructions: instructions,
        acc: 0,
        pointer: 0,
        terminated: false
      }
    end

    def run_with_fix(%__MODULE__{instructions: instructions} = program) do
      instructions
      |> Stream.filter(fn {_i, {op, _n}} -> op in ["jmp", "nop"] end)
      |> Stream.map(fn {i, _} -> program |> fix_instruction(i) |> run_with_loop_rescue() end)
      |> Enum.find(fn {result, _} -> result == :terminated end)
    end

    defp fix_instruction(%__MODULE__{instructions: instructions} = program, index) do
      new_instructions =
        Map.update!(instructions, index, fn
          {"jmp", n} -> {"nop", n}
          {"nop", n} -> {"jmp", n}
        end)

      %{program | instructions: new_instructions}
    end

    def run_with_loop_rescue(program, executed \\ MapSet.new())

    def run_with_loop_rescue(%__MODULE__{terminated: true} = program, _executed) do
      {:terminated, program}
    end

    def run_with_loop_rescue(%__MODULE__{terminated: false} = program, executed) do
      if MapSet.member?(executed, program.pointer) do
        {:loop, program}
      else
        program
        |> step()
        |> run_with_loop_rescue(MapSet.put(executed, program.pointer))
      end
    end

    def step(%__MODULE__{} = program) do
      apply_instruction(program, current_instruction(program))
    end

    defp current_instruction(%__MODULE__{instructions: instructions, pointer: pointer}) do
      instructions[pointer]
    end

    defp apply_instruction(%__MODULE__{} = program, {"acc", n}) do
      program
      |> Map.update!(:acc, &(&1 + n))
      |> jump(1)
    end

    defp apply_instruction(%__MODULE__{} = program, {"jmp", n}) do
      jump(program, n)
    end

    defp apply_instruction(%__MODULE__{} = program, {"nop", _}) do
      jump(program, 1)
    end

    defp apply_instruction(%__MODULE__{} = program, nil) do
      %{program | terminated: true}
    end

    defp jump(%__MODULE__{} = program, n) do
      %{program | pointer: program.pointer + n}
    end
  end

  alias __MODULE__.Program

  def part1(str \\ nil) do
    (str || input())
    |> parse_instructions()
    |> Program.new()
    |> last_acc_value_before_loop()
    |> IO.inspect()
  end

  def part2(str \\ nil) do
    (str || input())
    |> parse_instructions()
    |> Program.new()
    |> last_acc_value_after_terminated()
    |> IO.inspect()
  end

  defp last_acc_value_before_loop(%Program{} = program) do
    {:loop, %{acc: acc}} = Program.run_with_loop_rescue(program)
    acc
  end

  defp last_acc_value_after_terminated(%Program{} = program) do
    {:terminated, %{acc: acc}} = Program.run_with_fix(program)
    acc
  end

  defp parse_instructions(str) do
    str
    |> String.splitter("\n", trim: true)
    |> Stream.map(fn <<op::binary-size(3), ?\s, num::binary>> ->
      {op, String.to_integer(num)}
    end)
    |> Stream.with_index()
    |> Enum.into(%{}, fn {instruction, index} -> {index, instruction} end)
  end
end
