import Config

config :soundfeed,
  feeds_dir: "./feeds",
  feed_item_desc_length: 1000

config :soundfeed, SoundFeedWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: SoundFeedWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SoundFeedWeb.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: []

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
