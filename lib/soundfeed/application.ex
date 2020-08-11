defmodule SoundFeed.Application do
  use Application

  def start(_type, _args) do
    children = [
      SoundFeedWeb.Telemetry,
      {Phoenix.PubSub, name: SoundFeed.PubSub},
      SoundFeedWeb.Endpoint,
      SoundFeed.HTTP,
      {SoundFeed.Controller, client_id: client_id(), feeds_dir: feeds_dir()},
      {SoundFeed.Resolver, client_id: client_id()},
      SoundFeed.Reporter
    ]

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: SoundFeed.Supervisor
    )
  end

  defp client_id, do: Application.get_env(:soundfeed, :client_id)
  defp feeds_dir, do: Application.get_env(:soundfeed, :feeds_dir)

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SoundFeedWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
