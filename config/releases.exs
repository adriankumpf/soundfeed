import Config

config :soundfeed, client_id: System.fetch_env!("CLIENT_ID")

config :soundfeed, SoundFeedWeb.Endpoint,
  http: [:inet6, port: System.fetch_env!("PORT")],
  url: [host: System.fetch_env!("VIRTUAL_HOST"), port: 80]

config :logger,
  backends: [
    {LoggerTelegramBackend, :telegram_errors},
    {LoggerTelegramBackend, :telegram_notify},
    :console
  ],
  level: :info,
  handle_otp_reports: true,
  handle_sasl_reports: false,
  compile_time_purge_level: :info

config :logger, :telegram_errors,
  chat_id: System.fetch_env!("CHAT_ID"),
  token: System.fetch_env!("TOKEN"),
  level: :warn

config :logger, :telegram_notify,
  chat_id: System.fetch_env!("CHAT_ID"),
  token: System.fetch_env!("TOKEN"),
  metadata_filter: [notify: true],
  metadata: [:module]

config :logger, :console,
  format: "$time $metadata[$level] $levelpad$message\n",
  metadata: []
