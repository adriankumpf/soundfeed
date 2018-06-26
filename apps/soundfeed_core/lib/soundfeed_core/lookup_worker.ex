defmodule SoundfeedCore.LookupWorker do
  require Logger

  alias SoundfeedCore.Client
  alias SoundfeedCore.Models.User

  @name __MODULE__

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :new, []},
      restart: :transient,
      type: :worker
    }
  end

  @spec new() :: {:error, any} | {:ok, pid}
  def new do
    client_id = Application.get_env(:soundfeed_core, :client_id)
    _ = Logger.info("Starting LookupWorker")
    GenServer.start_link(__MODULE__, client_id, name: @name)
  end

  @spec lookup(String.t()) :: {:error, any} | {:ok, User.id()}
  def lookup(user) do
    GenServer.call(@name, {:lookup, user})
  end

  # GenServer API

  def init(client_id) do
    {:ok, client_id}
  end

  def handle_call({:lookup, user}, _from, client_id) do
    {:reply, Client.lookup(user, client_id), client_id}
  end
end
