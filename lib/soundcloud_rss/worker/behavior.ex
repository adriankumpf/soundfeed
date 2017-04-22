defmodule SoundcloudRss.Worker.Behavior do

  alias SoundcloudRss.Models.Like
  alias SoundcloudRss.Helper
  alias SoundcloudRss.Client
  alias SoundcloudRss.Feed

  @user_id Application.get_env(:soundcloud_rss, :user_id)

  def init do
    {Map.new, []}
  end

  def fetch_likes({likes, _order}) do
    fetched_favs = Client.fetch_likes(@user_id)
    updated_favs = insert(likes, fetched_favs)
    order = Enum.map(fetched_favs, fn %Like{id: id} -> id end)
    {updated_favs, order}
  end

  def get_likes({likes, _order}) do
    likes
  end

  def get_feed({likes, order}) do
    order
    |> Enum.map(fn id -> likes[id] end)
    |> Feed.build
  end

  defp insert(map, likes) do
    Enum.reduce(likes, map, fn %Like{id: id} = fav, acc ->
      Map.put_new(acc, id, %{fav | liked_at: Helper.now_rfc1123})
    end)
  end
end
