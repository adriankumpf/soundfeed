use Mix.Config

config :server, Server.Web.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn
