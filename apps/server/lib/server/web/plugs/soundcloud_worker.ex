defmodule Server.Web.Plugs.SoundcloudWorker do
  require Logger
  import Plug.Conn

  def start_worker(%Plug.Conn{params: %{"user_id" => user_id}, path_info: [_, _, "reposts.rss"]} = conn, _opts) do
    start(conn, :reposts, user_id)
  end
  def start_worker(%Plug.Conn{params: %{"user_id" => user_id}, path_info: [_, _, "tracks.rss"]} = conn, _opts) do
    start(conn, :tracks, user_id)
  end
  def start_worker(%Plug.Conn{params: %{"user_id" => user_id}, path_info: [_, _, "likes.rss"]} = conn, _opts) do
    start(conn, :likes, user_id)
  end
  def start_worker(conn, _opts), do: conn

  defp start(conn, type, user_id) do
    case Soundcloud.start(type, user_id) do
      {:ok, _pid} ->
        assign(conn, :worker, :running)
      {:error, reason} ->
        Logger.error("Worker failed: #{reason}")
        assign(conn, :worker, :failed)
    end
  end
end
