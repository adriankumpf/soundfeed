use Mix.Config

config :soundfeed_core, client_id: "${CLIENT_ID}"

# :ok = Application.ensure_started(:sasl)

config :logger,
  backends: [TelegramLoggerBackend, :console],
  level: :info,
  handle_otp_reports: true,
  handle_sasl_reports: false,
  compile_time_purge_level: :info

config :logger, :telegram,
  level: :warn,
  chat_id: "${CHAT_ID}",
  token: "${TOKEN}"
