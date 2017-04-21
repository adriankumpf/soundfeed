defmodule SoundcloudRss.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(SoundcloudRss.Worker, []),
    ]

    opts = [strategy: :one_for_one, name: SoundcloudRss.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
