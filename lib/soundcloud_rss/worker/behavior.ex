defmodule SoundcloudRss.Worker.Behavior do

  alias SoundcloudRss.Models.Favorit
  alias SoundcloudRss.Helper
  alias SoundcloudRss.Client
  alias SoundcloudRss.Feed

  @user_id Application.get_env(:soundcloud_rss, :user_id)

  def init do
    {Map.new, []}
  end

  def fetch_favorites({favorites, _order}) do
    fetched_favs = Client.fetch_favorites(@user_id)
    updated_favs = insert(favorites, fetched_favs)
    order = Enum.map(fetched_favs, fn %Favorit{id: id} -> id end)
    {updated_favs, order}
  end

  def get_favorties({favorites, _order}) do
    favorites
  end

  def get_feed({favorites, order}) do
    order
    |> Enum.map(fn id -> favorites[id] end)
    |> Feed.build
  end

  defp insert(map, favorites) do
    Enum.reduce(favorites, map, fn %Favorit{id: id} = fav, acc ->
      Map.put_new(acc, id, %{fav | liked_at: Helper.now_rfc1123})
    end)
  end
end
