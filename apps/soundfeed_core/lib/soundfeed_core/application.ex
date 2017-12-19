defmodule SoundfeedCore.Application do
  use Application

  def start(_type, _args) do
    children = [
      SoundfeedCore.Supervisor,
      SoundfeedCore.LookupWorker
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: __MODULE__
    )
  end
end
