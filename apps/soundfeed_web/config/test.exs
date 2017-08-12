use Mix.Config

config :soundfeed_web, SoundfeedWeb.Web.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn
