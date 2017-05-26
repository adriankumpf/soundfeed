use Mix.Config

config :server, Server.Web.Endpoint,
  on_init: {Server.Web.Endpoint, :load_from_system_env, []},
  url: [host: "localhost", port: {:system, "PORT"}],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Mix.Project.config[:version]

config :logger, level: :info

import_config "prod.secret.exs"
