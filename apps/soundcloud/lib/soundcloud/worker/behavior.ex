defmodule Soundcloud.Worker.Behavior do

  alias Soundcloud.Models.Track
  alias Soundcloud.Client
  alias Soundcloud.Feed

  @feeds_dir Application.get_env(:soundcloud, :feeds_dir)
  @desc_length 100

  def init({type, user_id}) do
    case {type, user_id, Map.new, []} |> fetch |> save_feed do
      {:error, reason} ->
        {:stop, reason}
      tracks ->
        {:ok, tracks}
    end
  end

  def fetch({type, user_id, tracks, _order}) do
    case Client.fetch(type, user_id) do
      {:ok, fetched_tracks} ->
        new_tracks = tracks |> insert(fetched_tracks)
        new_order = Enum.map(fetched_tracks, fn %Track{id: id} -> id end)
        {type, user_id, new_tracks, new_order}
      error ->
        error
    end
  end

  def save_feed({:error, _reason} = err), do: err
  def save_feed({type, user_id, _, _} = state) do
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

  def get_tracks({_type, _user_id, tracks, _order}) do
    tracks
  end

  def get_feed({type, user_id, tracks, order}) do
    order
    |> Enum.map(fn id -> tracks[id] end)
    |> Feed.build(type, user_id)
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
