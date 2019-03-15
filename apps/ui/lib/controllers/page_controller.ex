defmodule Ui.PageController do
  use Ui, :controller

  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, Ui.PageLive,
      session: %{
        host: Ui.Endpoint.url()
      }
    )
  end

  def faq(conn, _params) do
    render(conn, "faq.html")
  end
end
