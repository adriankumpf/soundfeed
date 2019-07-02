defmodule SoundFeedWeb.Plugs.SoundfeedWorker do
  use Plug.Builder
  require Logger

  alias Plug.Conn

  plug(:start_worker)
  plug(Plug.Static, at: "/", from: ".", gzip: false, only: ~w(feeds))

  def start_worker(
        %Conn{
          params: %{"user_id" => user_id},
          path_info: [_, _, "reposts.rss"]
        } = conn,
        _opts
      ),
      do: start(conn, :reposts, user_id)

  def start_worker(
        %Conn{
          params: %{"user_id" => user_id},
          path_info: [_, _, "tracks.rss"]
        } = conn,
        _opts
      ),
      do: start(conn, :tracks, user_id)

  def start_worker(
        %Conn{
          params: %{"user_id" => user_id},
          path_info: [_, _, "likes.rss"]
        } = conn,
        _opts
      ),
      do: start(conn, :likes, user_id)

  def start_worker(conn, _opts), do: conn

  defp start(conn, type, user_id) do
    case SoundFeed.new(type, user_id) do
      {:ok, _pid} ->
        conn

      {:error, :forbidden} ->
        Logger.warn("Worker could not be started: :forbidden")
        conn |> halt |> send_resp(503, "Please try again later.")

      {:error, reason} ->
        Logger.error("Worker could not be started: #{reason}")
        conn |> halt |> send_resp(500, "Something went wrong.")
    end
  end
end
