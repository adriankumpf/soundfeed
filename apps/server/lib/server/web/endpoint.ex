defmodule Server.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :server

  plug Plug.Static,
    at: "/", from: :server, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt
             android-chrome-192x192.png android-chrome-512x512.png
             apple-touch-icon.png browserconfig.xml favicon-16x16.png
             favicon-32x32.png manifest.json mstile-150x150.png
             safari-pinned-tab.svg )

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_server_key",
    signing_salt: "s4+M2c6q"

  plug Server.Web.Router

  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end
end
