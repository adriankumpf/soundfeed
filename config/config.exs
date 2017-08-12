use Mix.Config

import_config "../apps/*/config/config.exs"

config :soundfeed,

  feeds_dir: "./feeds",
  feed_item_desc_length: 1000,
  client_id: System.get_env("CLIENT_ID")
