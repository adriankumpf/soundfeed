defmodule Soundcloud.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Soundcloud.Worker, []),
    ]

    opts = [strategy: :one_for_one, name: Soundcloud.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
