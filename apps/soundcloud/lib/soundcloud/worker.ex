defmodule Soundcloud.Worker do
  use GenServer

  alias Soundcloud.Worker.Behavior

  @refresh_rate 1*60*1000

  ### Public API

  def start_link(user_id) do
    {:ok, pid} = ok = GenServer.start_link(__MODULE__, user_id)
    :yes = :global.register_name(user_id, pid)
    periodically_refresh(pid)
    ok
  end

  def get_likes(user_id) do
    GenServer.call({:global, user_id}, :get_likes)
  end

  def get_feed(user_id) do
    GenServer.call({:global, user_id}, :get_feed)
  end

  ### Server API

  def init(user_id) do
    {:ok, Behavior.init(user_id)}
  end

  def handle_info(:fetch_likes, state) do
    {:noreply, Behavior.fetch_likes(state)}
  end

  def handle_info(:save_feed, state) do
    Behavior.save_feed(state)
    {:noreply, state}
  end

  def handle_call(:get_likes, _from, state) do
    {:reply, Behavior.get_likes(state), state}
  end
  def handle_call(:get_feed, _from, state) do
    {:reply, Behavior.get_feed(state), state}
  end

  ### Private

  defp periodically_refresh(pid) do
    spawn_link(fn ->
      Process.link(pid)
      loop(pid)
    end)
  end

  defp loop(pid) do
    send pid, :fetch_likes
    send pid, :save_feed
    :timer.sleep(@refresh_rate)
    loop(pid)
  end
end
