defmodule Soundcloud.Worker.Behavior do

  alias Soundcloud.Models.Like
  alias Soundcloud.Client
  alias Soundcloud.Feed

  @feeds_dir Application.get_env(:soundcloud, :feeds_dir)
  @desc_length 100

  def init(user_id) do
    {user_id, Map.new, []}
  end

  def fetch_likes({user_id, likes, _order}) do
    fetched_favs = Client.fetch_likes(user_id)
    updated_favs = likes |> insert(fetched_favs)
    order = Enum.map(fetched_favs, fn %Like{id: id} -> id end)
    {user_id, updated_favs, order}
  end

  def get_likes({user_id, likes, _order}) do
    likes
  end

  def save_feed({user_id, _, _} = state) do
    path = "#{@feeds_dir}/#{user_id}/"
    save = fn -> File.write!(path <> "likes.rss", get_feed(state)) end

    case File.mkdir(path) do
      {:error, :eexist} -> save.()
      :ok -> save.()
      err -> err
    end
  end

  def get_feed({_user_id, likes, order}) do
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
