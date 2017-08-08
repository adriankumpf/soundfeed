use Mix.Config

config :server, Server.Web.Endpoint,
  load_from_system_env: true,
  url: [host: "localhost", port: {:system, "PORT"}],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Mix.Project.config[:version]

config :logger,
  handle_otp_reports: true,
  handle_sasl_reports: true

config :logger, backends: [{LoggerFileBackend, :error_log}]

config :logger, :error_log,
  path: "/var/log/soundfeed/error.log",
  level: :error

import_config "prod.secret.exs"
