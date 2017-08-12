defmodule Soundfeed.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Soundfeed.Supervisor, []),
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end
end
