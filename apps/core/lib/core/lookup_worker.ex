defmodule Core.LookupWorker do
  use GenServer

  require Logger

  alias Core.Client

  defstruct [:client_id]
  alias __MODULE__, as: State

  @name __MODULE__

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, @name))
  end

  def lookup(name \\ @name, user) do
    GenServer.call(name, {:lookup, user})
  end

  # GenServer API

  def init(opts) do
    {:ok, %State{client_id: Keyword.fetch!(opts, :client_id)}}
  end

  def handle_call({:lookup, user}, _from, %State{client_id: client_id} = state) do
    {:reply, Client.lookup(user, client_id), state}
  end
end
