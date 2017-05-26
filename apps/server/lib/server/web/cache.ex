defmodule Server.Web.Cache do
  use GenServer

  @moduledoc """
  A simple ETS based cache for expensive function calls.
  """

  @name :simple_cache
  @default_ttl 24*60*60

  # Client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Retrieve a cached value or apply the given function caching and returning
  the result.
  """
  def get(mod, fun, args, ttl \\ @default_ttl) do
    GenServer.call(__MODULE__, {:get, [mod, fun, args, ttl]})
  end

  # Server API

  def init(:ok) do
    opts = [:set, :protected, :named_table, read_concurrency: true]
    {:ok, :ets.new(@name, opts)}
  end

  def handle_call({:get, [mod, fun, args, ttl]}, _from, ets) do
    result = case lookup(ets, mod, fun, args) do
      nil -> cache_apply(ets, mod, fun, args, ttl)
      hit -> hit
    end
    {:reply, result, ets}
  end

  # Private Methods

  @doc """
  Lookup a cached result and check the freshness
  """
  defp lookup(ets, mod, fun, args) do
    case :ets.lookup(ets, [mod, fun, args]) do
      [result | _] -> check_freshness(result)
      [] -> nil
    end
  end

  @doc """
  Compare the result expiration against the current system time.
  """
  defp check_freshness({mfa, result, expiration}) do
    cond do
      expiration > :os.system_time(:seconds) -> result
      :else -> nil
    end
  end

  @doc """
  Apply the function, calculate expiration, and cache the result.
  """
  defp cache_apply(ets, mod, fun, args, ttl) do
    result = apply(mod, fun, args)
    expiration = :os.system_time(:seconds) + ttl
    :ets.insert(ets, {[mod, fun, args], result, expiration})
    result
  end
end
