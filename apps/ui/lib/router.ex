defmodule Ui.Router do
  use Ui, :router

  # import Phoenix.LiveView.Router

  alias Plug.Conn
  alias Ui.Plugs.SoundfeedWorker

  pipeline :browser do
    plug(:accepts, ["html"])
    # plug(Phoenix.LiveView.Flash)
    plug(:put_secure_browser_headers)
    plug(:put_cache_headers)
    plug(:put_layout, {Ui.LayoutView, :app})
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :feeds do
    plug(SoundfeedWorker)
  end

  scope "/", Ui do
    pipe_through(:browser)
    get("/", PageController, :index)
    get("/faq", PageController, :faq)
  end

  scope "/lookup", Ui do
    pipe_through(:api)
    get("/:user", ApiController, :show)
  end

  scope "/feeds", Ui do
    pipe_through(:feeds)
    get("/:user_id/likes.rss", FeedController, :dummy)
    get("/:user_id/tracks.rss", FeedController, :dummy)
    get("/:user_id/reposts.rss", FeedController, :dummy)
  end

  defp put_cache_headers(conn, _) do
    Conn.put_resp_header(conn, "cache-control", "public, max-age=86400")
  end
end
