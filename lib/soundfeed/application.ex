defmodule SoundFeed.Application do
  use Application

  def start(_type, _args) do
    children = [
      SoundFeed.Api,
      {SoundFeed.Controller, client_id: client_id(), feeds_dir: feeds_dir()},
      {Phoenix.PubSub, name: SoundFeed.PubSub},
      SoundFeedWeb.Endpoint,
      SoundFeed.Reporter
    ]

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: SoundFeed.Supervisor
    )
  end

  def client_id, do: Application.get_env(:soundfeed, :client_id)
  def feeds_dir, do: Application.get_env(:soundfeed, :feeds_dir)

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SoundFeedWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
