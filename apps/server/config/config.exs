use Mix.Config

# General application configuration
config :server,
  namespace: Server

# Configures the endpoint
config :server, Server.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "peMuYkVjSlLsaY4OZNaWRAHrctD8r9Alqb5ANg5xBEfSCciZSp6QcAxdbtBo+Z3o",
  render_errors: [view: Server.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Server.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
