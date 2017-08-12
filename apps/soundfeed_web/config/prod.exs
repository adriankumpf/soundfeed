use Mix.Config

config :soundfeed_web, SoundfeedWeb.Web.Endpoint,
  load_from_system_env: true,
  url: [host: "localhost", port: {:system, "PORT"}],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Mix.Project.config[:version],
  secret_key_base: System.get_env("KEY_BASE")

config :logger,
  handle_otp_reports: true,
  handle_sasl_reports: true

config :logger, backends: [{LoggerFileBackend, :error_log}]

config :logger, :error_log,
  path: "/var/log/soundfeed/error.log",
  level: :error
