["rel", "plugins", "*.exs"]
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
  default_release: :soundfeed,
  default_environment: :prod

environment :prod do
  set(include_erts: true)
  set(include_src: false)
  set(cookie: :"${ERLANG_COOKIE}")
end

release :soundfeed do
  set(version: current_version(:soundfeed_core))

  set(
    applications: [
      :runtime_tools,
      soundfeed_web: :permanent,
      soundfeed_core: :permanent
    ]
  )
end
