defmodule Soundcloud.Worker do
  use GenServer

  alias Soundcloud.Worker.Behavior

  @refresh_rate 3*60*60*1000

  ### Public API

  def start_link(type, user_id) do
    case :global.whereis_name({type, user_id}) do
      :undefined ->
        start_and_fetch(type, user_id)
      pid ->
        {:ok, pid}
    end
  end

  def get_tracks(type, user_id) do
    GenServer.call({:global, {type, user_id}}, :get_tracks)
  end

  def get_feed(type, user_id) do
    GenServer.call({:global, {type, user_id}}, :get_feed)
  end

  def get_user(type, user_id) do
    GenServer.call({:global, {type, user_id}}, :get_user)
  end

  ### Server API

  def init(user_id) do
    schedule_refresh()
    Behavior.init(user_id)
  end

  def handle_info(:fetch, state) do
    {:noreply, Behavior.fetch(state)}
  end

  def handle_info(:save_feed, state) do
    {:noreply, Behavior.save_feed(state)}
  end

  def handle_info(:refresh, state) do
    send(self(), :fetch)
    send(self(), :save_feed)
    schedule_refresh()
    {:noreply, state}
  end

  def handle_call(:get_tracks, _from, state) do
    {:reply, Behavior.get_tracks(state), state}
  end
  def handle_call(:get_feed, _from, state) do
    {:reply, Behavior.get_feed(state), state}
  end
  def handle_call(:get_user, _from, state) do
    {:reply, Behavior.get_user(state), state}
  end

  ### Private

  defp start_and_fetch(type, user_id) do
    case GenServer.start_link(__MODULE__, {type, user_id}) do
      ok = {:ok, pid} ->
        :yes = :global.register_name({type, user_id}, pid)
        ok
      err = {:error, _} ->
        err
    end
  end

  defp schedule_refresh() do
    Process.send_after(self(), :refresh, @refresh_rate)
  end
end
