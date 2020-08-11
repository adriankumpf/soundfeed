import Config

config :soundfeed, client_id: System.fetch_env!("CLIENT_ID")

config :soundfeed, SoundFeedWeb.Endpoint,
  http: [:inet6, port: System.fetch_env!("PORT")],
  url: [host: System.fetch_env!("VIRTUAL_HOST"), port: 80]

config :logger,
  backends: [:console],
  level: :info,
  handle_otp_reports: true,
  handle_sasl_reports: false,
  compile_time_purge_level: :info

config :logger, :console,
  format: "$time $metadata[$level] $levelpad$message\n",
  metadata: []
