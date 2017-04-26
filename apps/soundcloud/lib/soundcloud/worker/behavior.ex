defmodule Soundcloud.Worker.Behavior do

  alias Soundcloud.Models.Like
  alias Soundcloud.Client
  alias Soundcloud.Feed

  @feeds_dir Application.get_env(:soundcloud, :feeds_dir)
  @desc_length 100

  def init(user_id) do
    case {user_id, Map.new, []} |> fetch_likes |> save_feed do
      {:error, reason} ->
        {:stop, reason}
      likes ->
        {:ok, likes}
    end
  end

  def fetch_likes({user_id, likes, _order}) do
    case Client.fetch_likes(user_id) do
      {:ok, fetched_likes} ->
        new_likes = likes |> insert(fetched_likes)
        new_order = Enum.map(fetched_likes, fn %Like{id: id} -> id end)
        {user_id, new_likes, new_order}
      error ->
        error
    end
  end

  def save_feed({:error, _reason} = err), do: err
  def save_feed({user_id, _, _} = state) do
    path = "#{@feeds_dir}/#{user_id}/"

    save_and_return_state = fn ->
      File.write!(path <> "likes.rss", get_feed(state))
      state
    end

    case File.mkdir_p(path) do
      :ok -> save_and_return_state.()
      err -> err
    end
  end

  def get_likes({_user_id, likes, _order}) do
    likes
  end

  def get_feed({user_id, likes, order}) do
    order
    |> Enum.map(fn id -> likes[id] end)
    |> Feed.build(user_id)
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
