defmodule Ui.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ui,
      version: "0.0.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [mod: {Ui.Application, []}, extra_applications: [:logger, :runtime_tools]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.4"},
      {:jason, "~> 1.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:cowboy, "~> 2.3"},
      {:plug_cowboy, "~> 2.0"},
      {:core, in_umbrella: true}
    ]
  end
end
