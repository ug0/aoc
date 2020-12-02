defmodule Aoc.Input do
  defmacro __using__(_) do
    quote do
      defp input do
        case System.argv() do
          [file] -> File.read!(file)
          _ -> File.read!("#{__DIR__}/input.txt")
        end
      end

      defoverridable input: 0
    end
  end
end
