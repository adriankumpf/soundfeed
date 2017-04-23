defmodule Server.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Server.Web.Endpoint, []),
      # worker(Server.Worker, [arg1, arg2, arg3]),
    ]

    opts = [strategy: :one_for_one, name: Server.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
