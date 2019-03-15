use Mix.Config

config :ui, Ui.Endpoint,
  http: [port: 4000],
  debug_errors: false,
  code_reloader: true,
  check_origin: false,
  protocol_options: [
    max_header_name_length: 64,
    max_header_value_length: 140_096,
    max_headers: 100
  ],
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      "--display",
      "minimal",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :ui, Ui.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{lib/views/.*(ex)$},
      ~r{lib/templates/.*(eex)$},
      ~r{lib/live/.*(ex)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
