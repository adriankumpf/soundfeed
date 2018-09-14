defmodule Core.Application do
  use Application

  alias Core.{Controller, Resolver, Reporter}

  def start(_type, _args) do
    children = [
      {Controller, client_id: client_id(), feeds_dir: feeds_dir()},
      {Resolver, client_id: client_id()},
      Reporter
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end

  defp client_id, do: Application.get_env(:core, :client_id)
  defp feeds_dir, do: Application.get_env(:core, :feeds_dir)
end
