defmodule Soundcloud.Worker do
  use GenServer

  alias Soundcloud.Worker.Behavior

  @name __MODULE__
  @refresh_rate 12*60*60*1000

  ### Public API

  def start_link do
    {:ok, _} = ok = GenServer.start_link(__MODULE__, :ok, name: @name)
    spawn_link(&loop/0)
    ok
  end

  def get_likes do
    GenServer.call(@name, :get_likes)
  end

  def get_feed do
    GenServer.call(@name, :get_feed)
  end

  ### Server API

  def init(:ok) do
    {:ok, Behavior.init()}
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

  defp loop do
    send @name, :fetch_likes
    send @name, :save_feed
    :timer.sleep(@refresh_rate)
    loop()
  end
end
