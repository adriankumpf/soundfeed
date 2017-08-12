defmodule SoundfeedWeb.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(SoundfeedWeb.Web.Endpoint, []),
      worker(SoundfeedWeb.Web.Cache, []),
    ]

    opts = [strategy: :one_for_one, name: SoundfeedWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
