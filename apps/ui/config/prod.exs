use Mix.Config

config :ui, Ui.Endpoint,
  http: [:inet6, port: "${PORT}"],
  url: [host: "${HOST}", port: "${PORT}"],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: "."
