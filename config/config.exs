import Config

config :soundfeed,
  feeds_dir: "./feeds",
  feed_item_desc_length: 1000,
  namespace: SoundFeed

config :soundfeed, SoundFeedWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "PAXS5aJ9QgV3pNO7g/BVgWQg4+ZoUn0IrREEES/cILbFkagHXFE2p7xRuiZlN8do",
  render_errors: [view: SoundFeedWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: SoundFeed.PubSub,
  live_view: [signing_salt: "HUbY/YLd"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
