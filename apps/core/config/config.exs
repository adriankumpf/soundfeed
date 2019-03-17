use Mix.Config

config :core,
  feeds_dir: "./feeds",
  feed_item_desc_length: 1000,
  client_id: System.get_env("CLIENT_ID")

import_config "#{Mix.env()}.exs"