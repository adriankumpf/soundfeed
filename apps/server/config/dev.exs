use Mix.Config

config :server, Server.Web.Endpoint,
  http: [port: 4000],
  debug_errors: false,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../assets", __DIR__)]]

config :server, Server.Web.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{lib/server/web/views/.*(ex)$},
      ~r{lib/server/web/templates/.*(eex)$}
    ]
  ]

config :logger, :console,
  format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
