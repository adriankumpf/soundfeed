defmodule Soundfeed.Application do
  use Application

  def start(_type, _args) do
    children = [Soundfeed.Supervisor]

    Supervisor.start_link(children, [
      strategy: :one_for_one,
      name: __MODULE__
    ])
  end
end
