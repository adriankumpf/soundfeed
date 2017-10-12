defmodule SoundfeedCore.Worker.Impl do
  require Logger

  alias SoundfeedCore.Models.{Track, User}
  alias SoundfeedCore.Client
  alias SoundfeedCore.Feed

  @desc_length Application.get_env(:soundfeed_core, :feed_item_desc_length)
  @feeds_dir Application.get_env(:soundfeed_core, :feeds_dir)
  @timeout 65_000

  @typep tracks :: %{required(Track.id) => Track.t}
  @typep order  :: [Track.id]
  @typep state  :: {Client.id, Client.type, User.t, tracks, order}

  @spec init({Client.type, User.id}) :: {:error, any} | {:ok, state}
  def init({type, user_id}) do
    client_id =  Application.get_env(:soundfeed_core, :client_id)
    initital_state = {client_id, type, %User{id: user_id}, Map.new, []}

    t_user_info = Task.async(Client, :fetch, [:user, user_id, client_id])
    t_tracks = Task.async(fn -> fetch(initital_state) end)

    with {:ok, user = %User{}} <- Task.await(t_user_info, @timeout),
         {:ok, {_, type, _, tracks, order}} <- Task.await(t_tracks, @timeout),
         {:ok, state} <- save_feed({client_id, type, user, tracks, order}) do
      {:ok, state}
    else
      {:error, _reason} = err -> err
    end
  end

  @spec fetch(state) :: {:error, any} | {:ok, state}
  def fetch({client_id, type, %User{id: user_id} = user, tracks, _order}) do
    case Client.fetch(type, user_id, client_id) do
      {:ok, fetched_tracks} ->
        new_tracks = tracks |> insert(fetched_tracks)
        new_order = Enum.map(fetched_tracks, fn %Track{id: id} -> id end)
        {:ok, {client_id, type, user, new_tracks, new_order}}
      {:error, _reason} = err ->
        err
    end
  end

  @spec save_feed(state) :: {:error, any} | {:ok, state}
  def save_feed({_, type, %User{id: user_id}, _, _} = state) do
    path = "#{@feeds_dir}/#{user_id}/"

    case File.mkdir_p(path) do
      :ok ->
        File.write!(path <> "#{Atom.to_string(type)}.rss", get_feed(state))
        {:ok, state}
      err ->
        {:error, err}
    end
  end

  @spec get_tracks(state) :: [Track.t]
  def get_tracks({_client_id, _type, _user, tracks, _order}), do: tracks

  @spec get_user(state) :: User.t
  def get_user({_client_id, _type, user, _tracks, _order}), do: user

  @spec get_feed(state) :: Feed.t
  def get_feed({_client_id, type, user, tracks, order}) do
    order
    |> Enum.map(fn id -> tracks[id] end)
    |> Feed.build(type, user)
  end

  @spec insert(tracks, [Track.t]) :: tracks
  defp insert(map, tracks) do
    Enum.reduce(tracks, map, &do_insert/2)
  end

  @spec do_insert(Track.t, tracks) :: tracks
  defp do_insert(%Track{id: id, desc: nil} = track, acc) do
    Map.put_new(acc, id, %{track | desc: ""})
  end
  defp do_insert(%Track{id: id, desc: desc} = track, acc)
  when byte_size(desc) > @desc_length do
    {desc, _} = String.split_at(desc, @desc_length)
    Map.put_new(acc, id, %{track | desc: desc <> "..."})
  end
  defp do_insert(%Track{id: id, desc: desc} = track, acc) do
    Map.put_new(acc, id, %{track | desc: desc})
  end
  defp do_insert(track, acc) do
    _ = Logger.error("Could not process track: #{track}")
    acc
  end
end
