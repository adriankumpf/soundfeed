import Config

config :soundfeed, SoundFeedWeb.Endpoint,
  http: [port: 4001],
  server: true

config :logger, level: :warn
