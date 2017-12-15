use Mix.Config

config :soundfeed_web, SoundfeedWeb.Web.Endpoint,
  http: [port: "${PORT}"],
  url: [host: "${HOST}", port: "${PORT}"],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Mix.Project.config[:version]

config :logger, :console,
  format: "$time $metadata[$level] $levelpad$message\n",
  metadata: []
