defmodule Ui.Application do
  use Application

  alias Ui.{Endpoint, Cache}

  def start(_type, _args) do
    children = [
      Endpoint,
      Cache
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: __MODULE__
    )
  end
end
