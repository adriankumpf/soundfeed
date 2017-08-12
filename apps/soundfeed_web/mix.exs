defmodule SoundfeedWeb.Mixfile do
  use Mix.Project

  def project do
    [app: :soundfeed_web,
     version: version_from_file(),
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [mod: {SoundfeedWeb.Application, []},
     extra_applications: [:logger, :runtime_tools]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:cowboy, "~> 1.0"},
      {:logger_file_backend, "~> 0.0.9"},
      {:soundfeed_core, in_umbrella: true},
    ]
  end

  defp version_from_file(file \\ "../../VERSION") do
    String.trim(File.read!(file))
  end
end
