use Mix.Config

config :soundfeed, SoundFeedWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :logger, level: :info
