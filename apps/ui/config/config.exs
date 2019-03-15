use Mix.Config

config :ui, namespace: Ui

config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

config :ui, Ui.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: Ui.ErrorView, accepts: ~w(html json)],
  secret_key_base: "DEVlveb4J5vayq6Qr11J6l9ZESj6IF9kpr27VSSrDdVWwHYq3ar9abEczMuZxrCh",
  pubsub: [name: Ui.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "DEVxmbcq8Al1XXHfpzXyxohVQhe9eNh0"
  ]

import_config "#{Mix.env()}.exs"
