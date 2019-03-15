~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
  default_release: :default,
  default_environment: :prod

environment :prod do
  set(include_erts: true)
  set(include_src: false)
  set(cookie: :"${ERLANG_COOKIE}")
end

release :soundfeed do
  set(version: "0.0.0")

  set(
    applications: [
      :runtime_tools,
      logger_telegram_backend: :permanent,
      core: :permanent,
      ui: :permanent
    ]
  )
end
