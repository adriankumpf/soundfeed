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

  pipeline :feeds do
    plug :start_genserver
    plug Plug.Static,
      at: "/", from: :server, gzip: true
  end

  scope "/", Server.Web do
    pipe_through :browser
    get "/", PageController, :index
  end

  scope "/feeds", Server.Web do
    pipe_through :feeds
    get "/:feed", FeedController, :index
  end
end
