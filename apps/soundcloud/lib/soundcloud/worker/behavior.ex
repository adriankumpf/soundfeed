defmodule Soundcloud.Worker.Behavior do

  alias Soundcloud.Models.{Track, User}
  alias Soundcloud.Client
  alias Soundcloud.Feed

  @desc_length Application.get_env(:soundcloud, :feed_item_desc_length)
  @feeds_dir Application.get_env(:soundcloud, :feeds_dir)

  def init({type, user_id}) do
    initital_state = {type, %User{id: user_id}, Map.new, []}

    task_user_info = Task.async(fn -> fetch_user_info(user_id) end)
    task_tracks = Task.async(fn -> fetch(initital_state) end)

    with user = %User{} <- Task.await(task_user_info),
         {type, _user, tracks, order} <- Task.await(task_tracks),
         state = {_, _, _, _} <- save_feed({type, user, tracks, order}) do
      {:ok, state}
    else
      {:error, reason} -> {:stop, reason}
    end
  end

  def fetch_user_info(user_id) do
    case Client.fetch(:user, user_id) do
      {:ok, user} -> user
      error -> error
    end
  end

  def fetch({:error, _reason} = err), do: err
  def fetch({type, %User{id: user_id} = user, tracks, _order}) do
    case Client.fetch(type, user_id) do
      {:ok, fetched_tracks} ->
        new_tracks = tracks |> insert(fetched_tracks)
        new_order = Enum.map(fetched_tracks, fn %Track{id: id} -> id end)
        {type, user, new_tracks, new_order}
      error ->
        error
    end
  end

  def save_feed({:error, _reason} = err), do: err
  def save_feed({type, %User{id: user_id}, _, _} = state) do
    path = "#{@feeds_dir}/#{user_id}/"

    save_and_return_state = fn ->
      File.write!(path <> "#{Atom.to_string(type)}.rss", get_feed(state))
      state
    end

    case File.mkdir_p(path) do
      :ok -> save_and_return_state.()
      err -> err
    end
  end

  def get_tracks({_type, _user, tracks, _order}), do: tracks
  def get_user({_type, user, _tracks, _order}), do: user
  def get_feed({type, user, tracks, order}) do
    order
    |> Enum.map(fn id -> tracks[id] end)
    |> Feed.build(type, user)
  end


  defp insert(map, tracks) do
    Enum.reduce(tracks, map, &do_insert/2)
  end

  defp do_insert(%Track{id: id, description: nil} = fav, acc) do
    Map.put_new(acc, id, %{fav | description: ""})
  end
  defp do_insert(%Track{id: id, description: desc} = fav, acc) when byte_size(desc) > @desc_length do
    {description, _} = String.split_at(desc, @desc_length)
    Map.put_new(acc, id, %{fav | description: description <> "..."})
  end
  defp do_insert(%Track{id: id, description: description} = fav, acc) do
    Map.put_new(acc, id, %{fav | description: description})
  end
end
