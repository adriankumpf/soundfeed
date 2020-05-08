defmodule SoundFeedWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :soundfeed

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_soundfeed_key",
    signing_salt: "VRUuzIw5"
  ]

  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :soundfeed,
    gzip: true,
    only: ~w(css fonts images js favicon.ico robots.txt
             android-chrome-192x192.png android-chrome-512x512.png
             apple-touch-icon.png browserconfig.xml favicon-16x16.png
             favicon-32x32.png manifest.json mstile-150x150.png
             safari-pinned-tab.svg ),
    headers: %{"cache-control" => "public, max-age=31536000"}

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug SoundFeedWeb.Router
end
