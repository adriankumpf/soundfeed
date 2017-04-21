defmodule SoundcloudRss.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Starts a worker by calling: SoundcloudRss.Worker.start_link(arg1, arg2, arg3)
      # worker(SoundcloudRss.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SoundcloudRss.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
