defmodule SoundcloudRss.Worker do
  use GenServer

  alias SoundcloudRss.Models.Favorit
  alias SoundcloudRss.Helper
  alias SoundcloudRss.Client
  alias SoundcloudRss.Feed

  @name __MODULE__
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

  def get_feed do
    GenServer.call(@name, :get_feed)
  end

  ### Server API

  def init(:ok) do
    {:ok, {Map.new, []}}
  end

  def handle_info(:fetch_favorites, {favorites, _order}) do
    fetched_favs = Client.fetch_favorites(@user_id)
    updated_favs = insert(favorites, fetched_favs)
    order = Enum.map(fetched_favs, fn %Favorit{id: id} -> id end)
    {:noreply, {updated_favs, order}}
  end

  def handle_call(:get_favorites, _from, {favorites, _order} = state) do
    {:reply, favorites, state}
  end

  def handle_call(:get_feed, _from, {favorites, order} = state) do
    favs = Enum.map(order, fn id -> favorites[id] end)
    {:reply, Feed.build(favs), state}
  end

  ### Private

  defp loop do
    send @name, :fetch_favorites
    :timer.sleep(@refresh_rate)
    loop()
  end

  defp insert(map, favorites) do
    Enum.reduce(favorites, map, fn %Favorit{id: id} = fav, acc ->
      Map.put_new(acc, id, %{fav | liked_at: Helper.now_rfc1123})
    end)
  end
end
