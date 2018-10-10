defmodule SoundFeed.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp deps do
    [
      {:distillery, "~> 2.0"},
      {:logger_telegram_backend, "~> 1.1", only: :prod}
    ]
  end
end
