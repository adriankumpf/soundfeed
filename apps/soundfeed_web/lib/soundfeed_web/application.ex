defmodule SoundfeedWeb.Application do
  use Application

  def start(_type, _args) do
    children = [
      SoundfeedWeb.Web.Endpoint,
      SoundfeedWeb.Web.Cache
    ]

    Supervisor.start_link(children, [
      strategy: :one_for_one,
      name: __MODULE__
    ])
  end
end
