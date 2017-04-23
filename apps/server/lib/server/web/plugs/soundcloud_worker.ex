defmodule Server.Web.Plugs.SoundcloudWorker do
  import Plug.Conn

  def fetch_user_id(%Plug.Conn{params: %{"feed" => << "likes_" <> user_id >>}} = conn, _opts) do
    user_id = user_id
              |> String.split(".")
              |> List.first
    assign(conn, :user_id, user_id)
  end
  def fetch_user_id(conn, _opts), do: conn

  def start_genserver(%Plug.Conn{assigns: %{user_id: user_id}} = conn, _opts) do
    {:ok, _pid} = Soundcloud.start(user_id)
    conn
  end
  def start_genserver(conn, _opts), do: conn
end
