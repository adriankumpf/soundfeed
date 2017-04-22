defmodule SoundcloudRss.Worker.Behavior do

  alias SoundcloudRss.Models.Like
  alias SoundcloudRss.Helper
  alias SoundcloudRss.Client
  alias SoundcloudRss.Feed

  @feeds_dir Application.get_env(:soundcloud_rss, :feeds_dir)
  @user_id Application.get_env(:soundcloud_rss, :user_id)
  @desc_length 100

  def init do
    {Map.new, []}
  end

  def fetch_likes({likes, _order}) do
    fetched_favs = Client.fetch_likes(@user_id)
    updated_favs = likes |> insert(fetched_favs)
    order = Enum.map(fetched_favs, fn %Like{id: id} -> id end)
    {updated_favs, order}
  end

  def get_likes({likes, _order}) do
    likes
  end

  def save_feed(state) do
    File.write!("#{@feeds_dir}/likes_#{@user_id}.rss", get_feed(state))
  end

  def get_feed({likes, order}) do
    order
    |> Enum.map(fn id -> likes[id] end)
    |> Feed.build
  end

  defp insert(map, likes) do
    Enum.reduce(likes, map, &do_insert/2)
  end

  defp do_insert(%Like{id: id, description: nil} = fav, acc) do
    Map.put_new(acc, id, %{fav | description: ""})
  end
  defp do_insert(%Like{id: id, description: desc} = fav, acc) when byte_size(desc) > @desc_length do
    {description, _} = String.split_at(desc, @desc_length)
    Map.put_new(acc, id, %{fav | description: description <> "..."})
  end
  defp do_insert(%Like{id: id, description: description} = fav, acc) do
    Map.put_new(acc, id, %{fav | description: description})
  end
end
