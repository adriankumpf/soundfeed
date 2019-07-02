defmodule SoundFeedWeb.PageController do
  use SoundFeedWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def faq(conn, _params) do
    render(conn, "faq.html")
  end
end
