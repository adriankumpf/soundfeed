defmodule SoundcloudRss.Worker do
  use GenServer

  alias SoundcloudRss.Worker.Behavior

  @name __MODULE__
  @refresh_rate 12*60*60*1000

  ### Public API

  def start_link do
    {:ok, _} = ok = GenServer.start_link(__MODULE__, :ok, name: @name)
    spawn_link(&loop/0)
    ok
  end

  def get_favorties do
    GenServer.call(@name, :get_favorites)
  end

  def get_feed do
    GenServer.call(@name, :get_feed)
  end

  ### Server API

  def init(:ok) do
    {:ok, Behavior.init()}
  end

  def handle_info(:fetch_favorites, state) do
    {:noreply, Behavior.fetch_favorites(state)}
  end

  def handle_call(:get_favorites, _from, state) do
    {:reply, Behavior.get_favorties(state), state}
  end

  def handle_call(:get_feed, _from, state) do
    {:reply, Behavior.get_feed(state), state}
  end

  ### Private

  defp loop do
    send @name, :fetch_favorites
    :timer.sleep(@refresh_rate)
    loop()
  end
end
