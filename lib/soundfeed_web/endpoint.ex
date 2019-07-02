defmodule SoundFeedWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :soundfeed

  plug Plug.Static,
    at: "/",
    from: :soundfeed,
    gzip: false,
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
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug SoundFeedWeb.Router
end
