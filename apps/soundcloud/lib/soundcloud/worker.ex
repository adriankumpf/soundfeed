defmodule Soundcloud.Worker do
  use GenServer

  alias Soundcloud.Worker.Behavior

  @refresh_rate 3*60*60*1000

  ### Public API

  def start_link(user_id) do
    case :global.whereis_name(user_id) do
      :undefined ->
        start_and_fetch(user_id)
      pid ->
        {:ok, pid}
    end
  end

  def get_likes(user_id) do
    GenServer.call({:global, user_id}, :get_likes)
  end

  def get_feed(user_id) do
    GenServer.call({:global, user_id}, :get_feed)
  end

  ### Server API

  def init(user_id) do
    Behavior.init(user_id)
  end

  def handle_info(:fetch_likes, state) do
    {:noreply, Behavior.fetch_likes(state)}
  end

  def handle_info(:save_feed, state) do
    {:noreply, Behavior.save_feed(state)}
  end

  def handle_call(:get_likes, _from, state) do
    {:reply, Behavior.get_likes(state), state}
  end
  def handle_call(:get_feed, _from, state) do
    {:reply, Behavior.get_feed(state), state}
  end

  ### Private

  defp start_and_fetch(user_id) do
    case GenServer.start_link(__MODULE__, user_id) do
      ok = {:ok, pid} ->
        :yes = :global.register_name(user_id, pid)
        periodically_refresh(pid)
        ok
      err = {:error, _} ->
        err
    end
  end

  defp periodically_refresh(pid) do
    spawn_link(fn ->
      Process.link(pid)
      loop(pid)
    end)
  end

  defp loop(pid) do
    :timer.sleep(@refresh_rate)
    send pid, :fetch_likes
    send pid, :save_feed
    loop(pid)
  end
end
