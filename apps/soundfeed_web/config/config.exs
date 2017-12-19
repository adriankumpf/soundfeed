use Mix.Config

config :soundfeed_web, namespace: SoundfeedWeb

config :soundfeed_web, SoundfeedWeb.Web.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: SoundfeedWeb.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SoundfeedWeb.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console, format: "$time [$level] $message\n"

import_config "#{Mix.env()}.exs"
