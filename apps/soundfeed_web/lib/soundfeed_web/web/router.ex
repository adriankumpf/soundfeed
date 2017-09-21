defmodule SoundfeedWeb.Web.Router do
  use SoundfeedWeb.Web, :router

  alias SoundfeedWeb.Web.Plugs.SoundfeedWorker
  alias Plug.Conn

  pipeline :browser do
    plug :accepts, ["html"]
    plug :put_secure_browser_headers
    plug :put_cache_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :feeds do
    plug SoundfeedWorker
  end

  scope "/", SoundfeedWeb.Web do
    pipe_through :browser
    get "/", PageController, :index
    get "/faq", PageController, :faq
  end

  scope "/lookup", SoundfeedWeb.Web do
    pipe_through :api
    get "/:user", ApiController, :show
  end

  scope "/feeds", SoundfeedWeb.Web do
    pipe_through :feeds
    get "/:user_id/likes.rss", FeedController, :dummy
    get "/:user_id/tracks.rss", FeedController, :dummy
    get "/:user_id/reposts.rss", FeedController, :dummy
  end

  defp put_cache_headers(conn, _) do
    Conn.put_resp_header(conn, "cache-control", "public, max-age=86400")
  end
end
