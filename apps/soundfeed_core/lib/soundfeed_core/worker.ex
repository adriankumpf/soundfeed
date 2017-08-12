defmodule SoundfeedCore.Worker do

  alias SoundfeedCore.Worker.Server

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :new, []},
      restart: :transient,
      type: :worker
    }
  end

  def new(type, user_id) do
    case :global.whereis_name({type, user_id}) do
      :undefined -> start_and_register(type, user_id)
      pid -> {:ok, pid}
    end
  end

  def get_tracks(type, user_id), do:
    GenServer.call({:global, {type, user_id}}, :get_tracks)

  def get_feed(type, user_id), do:
    GenServer.call({:global, {type, user_id}}, :get_feed)

  def get_user(type, user_id), do:
    GenServer.call({:global, {type, user_id}}, :get_user)

  defp start_and_register(type, user_id) do
    case GenServer.start_link(Server, {type, user_id}) do
      ok = {:ok, pid} ->
        :yes = :global.register_name({type, user_id}, pid)
        ok
      err = {:error, _} ->
        err
    end
  end
end
