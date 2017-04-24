defmodule Server.Web.FeedController do
  use Server.Web, :controller

  # Usually Plug.Static handles the requests.
  # This is called if e.g. the worker crashed or the user doesn't exist.
  def index(conn, _params) do
    conn
    |> put_status(:not_found)
    |> render(Server.Web.ErrorView, "404.html")
  end
end
