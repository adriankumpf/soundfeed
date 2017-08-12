use Mix.Config

import_config "../apps/*/config/config.exs"

config :soundfeed,

  feeds_dir: "./feeds",
  feed_item_desc_length: 1000

  # Soundcloud credentials
  #
  # Format:
  #   client_id: "yourClientId"

  import_config "client_id.secret.exs"
