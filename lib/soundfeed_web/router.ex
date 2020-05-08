defmodule SoundFeedWeb.Router do
  use SoundFeedWeb, :router

  alias SoundFeedWeb.Plugs.SoundfeedWorker

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_cache_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :feeds do
    plug SoundfeedWorker
  end

  scope "/", SoundFeedWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/faq", PageController, :faq
  end

  scope "/lookup", SoundFeedWeb do
    pipe_through :api
    get("/:user", ApiController, :show)
  end

  scope "/feeds", SoundFeedWeb do
    pipe_through :feeds
    get "/:user_id/likes.rss", FeedController, :dummy
    get "/:user_id/tracks.rss", FeedController, :dummy
    get "/:user_id/reposts.rss", FeedController, :dummy
  end

  defp put_cache_headers(conn, _) do
    put_resp_header(conn, "cache-control", "public, max-age=86400")
  end
end
