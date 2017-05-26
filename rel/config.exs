Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"a1dA<A]|3A&,6j7cAv|@=,%@Ovygvhv~]tHc2!P8h}K<!npDEH(e&d2T/$dfhly6"
end

release :soundcloud_rss do
  set version: "0.1.0"
  set applications: [
    :runtime_tools,
    server: :permanent,
    soundcloud: :permanent
  ]
end

