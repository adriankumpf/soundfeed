defmodule Server.Web.Plugs.SoundcloudWorker do
  import Plug.Conn

  def start_genserver(%Plug.Conn{params: %{"user_id" => user_id}} = conn, _opts) do
    {:ok, _pid} = Soundcloud.start(user_id)
    conn
  end
  def start_genserver(conn, _opts), do: conn
end
