defmodule Server.Web.FeedController do
  use Server.Web, :controller

  def index(conn, _params) do
    IO.inspect "in!!"
    conn
  end
end
