defmodule Core.Application do
  use Application

  alias Core.{Controller, Resolver, Reporter}

  def start(_type, _args) do
    children = [
      Controller,
      {Resolver, client_id: client_id()},
      Reporter
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end

  def client_id do
    Application.get_env(:core, :client_id)
  end
end
