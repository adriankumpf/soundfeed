defmodule Server.Web.PageController do
  use Server.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def faq(conn, _params) do
    render conn, "faq.html"
  end
end
