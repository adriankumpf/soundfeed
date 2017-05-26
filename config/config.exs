use Mix.Config

import_config "../apps/*/config/config.exs"

config :soundcloud,

  # Project specifics
  feeds_dir: "./feeds"

  # Soundcloud credentials
  import_config "client_id.secret.exs"
