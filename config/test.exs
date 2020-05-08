use Mix.Config

config :soundfeed, SoundFeedWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn
