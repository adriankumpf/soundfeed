defmodule SoundfeedCore.Worker do
  alias SoundfeedCore.{Client, Feed}
  alias SoundfeedCore.Models.{Track, User}
  alias SoundfeedCore.Worker.Server

  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :new, args},
      restart: :transient,
      type: :worker
    }
  end

  @spec new(Client.type(), User.id()) :: {:error, any} | {:ok, pid}
  def new(type, user_id) do
    case :global.whereis_name({type, user_id}) do
      :undefined ->
        GenServer.start_link(Server, {type, user_id}, name: {:global, {type, user_id}})

      pid ->
        {:ok, pid}
    end
  end

  @spec get_tracks(Client.type(), User.id()) :: {:error, any} | {:ok, [Track.t()]}
  def get_tracks(type, user_id), do: GenServer.call({:global, {type, user_id}}, :get_tracks)

  @spec get_feed(Client.type(), User.id()) :: {:error, any} | {:ok, Feed.t()}
  def get_feed(type, user_id), do: GenServer.call({:global, {type, user_id}}, :get_feed)

  @spec get_user(Client.type(), User.id()) :: {:error, any} | {:ok, User.t()}
  def get_user(type, user_id), do: GenServer.call({:global, {type, user_id}}, :get_user)
end
