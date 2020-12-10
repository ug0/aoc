defmodule Aoc.Cache do
  def new do
    :ets.new(nil, [:public, :set])
  end

  def with_cache(cache, key, fun) do
    case get(cache, key) do
      nil ->
        value = fun.()
        put(cache, key, value)
        value

      value ->
        value
    end
  end

  def get(cache, key) do
    case :ets.lookup(cache, key) do
      [] -> nil
      [{^key, value}] -> value
    end
  end

  def put(cache, key, value) do
    :ets.insert(cache, {key, value})
  end
end
