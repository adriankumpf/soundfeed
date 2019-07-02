import Config

config :soundfeed, SoundFeedWeb.Endpoint,
  root: ".",
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  version: Application.spec(:soundfeed, :vsn)

config :logger, level: :info
