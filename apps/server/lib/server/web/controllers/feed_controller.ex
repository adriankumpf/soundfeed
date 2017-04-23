defmodule Server.Web.FeedController do
  use Server.Web, :controller

  def index(%Plug.Conn{assigns: %{user_id: user_id}} = conn, _params) do
    conn
    |> put_resp_content_type("application/rss+xml")
    |> text(Soundcloud.get_feed(user_id))
  end
  def index(conn, _params) do
    conn
    |> put_status(:not_found)
    |> render(Server.Web.ErrorView, "404.html")
  end
end
