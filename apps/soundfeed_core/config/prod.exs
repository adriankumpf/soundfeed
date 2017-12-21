use Mix.Config

config :soundfeed_core, client_id: "${CLIENT_ID}"

# :ok = Application.ensure_started(:sasl)

config :logger,
  backends: [
    {TelegramLoggerBackend, :telegram_errors},
    {TelegramLoggerBackend, :telegram_notify},
    :console
  ],
  level: :info,
  handle_otp_reports: true,
  handle_sasl_reports: false,
  compile_time_purge_level: :info

config :logger, :telegram_errors,
  chat_id: "${CHAT_ID}",
  token: "${TOKEN}",
  level: :warn

config :logger, :telegram_notify,
  chat_id: "${CHAT_ID}",
  token: "${TOKEN}",
  metadata_filter: [notify: true],
  metadata: [:module]
