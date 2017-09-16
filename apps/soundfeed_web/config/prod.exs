use Mix.Config

config :soundfeed_web, SoundfeedWeb.Web.Endpoint,
  http: [port: "${PORT}"],
  url: [host: "${HOST}", port: "${PORT}"],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Mix.Project.config[:version]

:ok = Application.ensure_started(:sasl)

config :logger,
  backends: [:console],
  level: :info,
  handle_otp_reports: true,
  handle_sasl_reports: true,
  compile_time_purge_level: :info

config :logger, :console,
  format: "$time $metadata[$level] $levelpad$message\n",
  metadata: []
