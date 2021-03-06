defmodule SoundFeedWeb.Plugs.SoundfeedWorker do
  use Plug.Builder
  require Logger

  alias Plug.Conn

  @content_types for kind <- [:tracks, :likes],
                     do: {"#{kind}.rss", "application/rss+xml; charset=utf-8"},
                     into: %{}

  plug :start_worker
  plug Plug.Static, at: "/", from: ".", only: ~w(feeds), content_types: @content_types

  def start_worker(%Conn{params: %{"user_id" => user_id}, path_info: [_, _, fname]} = conn, _opts) do
    case fname do
      "tracks.rss" -> SoundFeed.Controller.monitor_tracks(user_id)
      "likes.rss" -> SoundFeed.Controller.monitor_likes(user_id)
    end
    |> case do
      :ok ->
        conn

      {:error, :not_found} ->
        conn |> halt |> send_resp(404, "Not found")

      {:error, :forbidden} ->
        Logger.warning("Worker could not be started: :forbidden")
        conn |> halt |> send_resp(503, "Please try again later")

      {:error, reason} ->
        Logger.error("Worker could not be started: #{inspect(reason)}")
        conn |> halt |> send_resp(500, "Something went wrong")
    end
  end
end
