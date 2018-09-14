use Mix.Config

config :ui, namespace: Ui

config :ui, Ui.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: Ui.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Ui.PubSub, adapter: Phoenix.PubSub.PG2]

import_config "#{Mix.env()}.exs"
