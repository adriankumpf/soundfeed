defmodule SoundFeedWeb.PageController do
  use SoundFeedWeb, :controller

  def index(conn, _params) do
    conn
    |> Plug.Conn.assign(:script, "/js/app.js")
    |> render("index.html")
  end

  def faq(conn, _params) do
    render(conn, "faq.html")
  end
end
