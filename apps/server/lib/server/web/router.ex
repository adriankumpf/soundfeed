defmodule Server.Web.Router do
  use Server.Web, :router

  import Server.Web.Plugs.SoundcloudWorker

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :feeds do
    plug :start_worker
    plug Plug.Static,
      at: "/", from: :server, gzip: true
  end

  scope "/", Server.Web do
    pipe_through :browser
    get "/", PageController, :index
    get "/faq", PageController, :faq
  end

  scope "/lookup", Server.Web do
    pipe_through :api
    get "/:user", ApiController, :show
  end

  scope "/feeds", Server.Web do
    pipe_through :feeds
    get "/:user_id/likes.rss", FeedController, :index
    get "/:user_id/tracks.rss", FeedController, :index
    get "/:user_id/reposts.rss", FeedController, :index
  end
end
