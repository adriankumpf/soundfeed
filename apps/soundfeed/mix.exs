defmodule Soundfeed.Mixfile do
  use Mix.Project

  def project do
    [app: :soundfeed,
     version: version_from_file(),
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.5",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Soundfeed.Application, []}]
  end

  defp deps do
    [
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:timex, "~> 3.1"}
    ]
  end

  defp version_from_file(file \\ "../../VERSION") do
    String.trim(File.read!(file))
  end
end
