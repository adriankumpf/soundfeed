defmodule SoundFeedWeb.Cache do
  @moduledoc """
  A simple ETS based cache for expensive function calls.
  """

  use GenServer

  @name :simple_cache
  @default_ttl_ms :timer.hours(24)

  def start_link([]) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Retrieve a cached value or apply the given function caching and returning
  the result.
  """
  def get(mod, fun, args, ttl \\ @default_ttl_ms) do
    GenServer.call(__MODULE__, {:get, [mod, fun, args, ttl]})
  end

  @impl true
  def init(_args) do
    {:ok, :ets.new(@name, [:set, :protected, :named_table, read_concurrency: true])}
  end

  @impl true
  def handle_call({:get, [mod, fun, args, ttl]}, _from, ets) do
    result =
      case lookup(ets, mod, fun, args) do
        nil -> cache_apply(ets, mod, fun, args, ttl)
        hit -> hit
      end

    {:reply, result, ets}
  end

  @impl true
  def handle_info({:expire, [mod, fun, args]}, ets) do
    :ets.delete(ets, [mod, fun, args])
    {:noreply, ets}
  end

  defp lookup(ets, mod, fun, args) do
    case :ets.lookup(ets, [mod, fun, args]) do
      [{_mfa, result} | _] -> result
      [] -> nil
    end
  end

  defp cache_apply(ets, mod, fun, args, ttl) do
    result = apply(mod, fun, args)
    key = [mod, fun, args]
    :ets.insert(ets, {key, result})
    Process.send_after(__MODULE__, {:expire, key}, ttl)
    result
  end
end
