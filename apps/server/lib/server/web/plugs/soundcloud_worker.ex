defmodule Server.Web.Plugs.SoundcloudWorker do
  import Plug.Conn

  def start_worker(%Plug.Conn{params: %{"user_id" => user_id}} = conn, _opts) do
      case Soundcloud.start(user_id) do
        {:ok, _pid} ->
          assign(conn, :worker, :running)
        {:error, _reason} ->
          assign(conn, :worker, :failed)
      end
  end
  def start_worker(conn, _opts), do: conn
end
