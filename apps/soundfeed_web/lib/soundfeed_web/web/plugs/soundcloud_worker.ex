defmodule SoundfeedWeb.Web.Plugs.SoundfeedWorker do
  use Plug.Builder
  require Logger

  alias Plug.Conn

  plug :start_worker
  plug Plug.Static,
    at: "/", from: ".", gzip: true,
    only: ~w(feeds)

  def start_worker(%Conn{params: %{"user_id" => user_id}, path_info: [_, _, "reposts.rss"]} = conn, _opts) do
    start(conn, :reposts, user_id)
  end
  def start_worker(%Conn{params: %{"user_id" => user_id}, path_info: [_, _, "tracks.rss"]} = conn, _opts) do
    start(conn, :tracks, user_id)
  end
  def start_worker(%Conn{params: %{"user_id" => user_id}, path_info: [_, _, "likes.rss"]} = conn, _opts) do
    start(conn, :likes, user_id)
  end
  def start_worker(conn, _opts), do: conn

  defp start(conn, type, user_id) do
    case Soundfeed.new(type, user_id) do
      {:ok, _pid} ->
        conn
      {:error, :forbidden} ->
        conn |> halt |> send_resp( 503, "Please try again in a few minutes.")
      {:error, reason} ->
        Logger.error("Worker failed: #{reason}")
        conn |> halt |> send_resp( 500, "Something went wrong.")
    end
  end
end
