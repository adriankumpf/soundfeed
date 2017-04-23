use Mix.Config

import_config "../apps/*/config/config.exs"

config :soundcloud,

  # Soundcloud credentials
  client_id: "yourClientId",
  user_id: "yourUserId",

  # Project specifics
  feeds_dir: "./apps/server/priv/static/feeds"
