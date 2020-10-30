import Config

defmodule Helper do
  def fetch_env!(varname, defaults \\ []) do
    case config_env() do
      :prod -> System.fetch_env!(varname)
      env -> System.get_env(varname, defaults[env] || defaults[:all])
    end
  end
end

config :soundfeed, client_id: Helper.fetch_env!("CLIENT_ID")

config :soundfeed, SoundFeedWeb.Endpoint,
  http: [:inet6, port: Helper.fetch_env!("PORT", dev: "4000", test: "4002")],
  url: [host: System.get_env("VIRTUAL_HOST", "localhost"), port: 80]
