defmodule SoundFeedWeb.Plugs.SoundfeedWorker do
  use Plug.Builder
  require Logger

  alias Plug.Conn

  @content_types for kind <- [:reposts, :tracks, :likes],
                     do: {"#{kind}.rss", "application/rss+xml; charset=utf-8"},
                     into: %{}

  plug :start_worker
  plug Plug.Static, at: "/", from: ".", only: ~w(feeds), content_types: @content_types

  def start_worker(%Conn{params: %{"user_id" => user_id}, path_info: [_, _, fname]} = conn, _opts) do
    fname
    |> parse_filename()
    |> SoundFeed.new(user_id)
    |> case do
      {:ok, _pid} ->
        conn

      {:error, :forbidden} ->
        Logger.warn("Worker could not be started: :forbidden")
        conn |> halt |> send_resp(503, "Please try again later.")

      {:error, reason} ->
        Logger.error("Worker could not be started: #{inspect(reason)}")
        conn |> halt |> send_resp(500, "Something went wrong.")
    end
  end

  defp parse_filename("reposts.rss"), do: :reposts
  defp parse_filename("tracks.rss"), do: :tracks
  defp parse_filename("likes.rss"), do: :likes
end
