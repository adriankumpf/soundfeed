use Mix.Config

config :ui, Ui.Endpoint,
  http: [:inet6, port: "${PORT}"],
  url: [host: "${HOST}", port: "${PORT}"],
  secret_key_base: "${KEY_BASE}",
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  live_view: [
    signing_salt: "${SIGNING_SALT}"
  ]
