use Mix.Config

if Mix.env() == :prod do
  # :ok = Application.ensure_started(:sasl)

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
    chat_id: "${CHAT_ID}",
    token: "${TOKEN}",
    level: :warn

  config :logger, :telegram_notify,
    chat_id: "${CHAT_ID}",
    token: "${TOKEN}",
    metadata_filter: [notify: true],
    metadata: [:module]

  config :logger, :console,
    format: "$time $metadata[$level] $levelpad$message\n",
    metadata: []
end

import_config "../apps/*/config/config.exs"
