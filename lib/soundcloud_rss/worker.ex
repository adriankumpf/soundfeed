defmodule SoundcloudRss.Worker do
  use GenServer

  alias SoundcloudRss.Client

  @name SoundcloudRssWorker
  @user_id Application.get_env(:soundcloud_rss, :user_id)
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

  ### Server API

  def init(:ok) do
    {:ok, []}
  end

  def handle_info(:fetch_favorites, _state) do
    {:noreply, Client.fetch_favorites(@user_id)}
  end

  def handle_call(:get_favorites, _from, state) do
    {:reply, state, state}
  end

  ### Private

  defp loop do
    send @name, :fetch_favorites
    :timer.sleep(@refresh_rate)
    loop()
  end
end
