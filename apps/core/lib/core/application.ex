defmodule Core.Application do
  use Application

  def start(_type, _args) do
    children = [
      Core.Supervisor,
      Core.LookupWorker,
      Core.Reporter
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: __MODULE__
    )
  end
end
