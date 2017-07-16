defmodule Soundcloud.Supervisor do
  use Supervisor

  @name __MODULE__

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: @name)
  end

  def init(_) do
    children = [
      worker(Soundcloud.Worker, [], function: :new, restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def new(type, user_id) do
    Supervisor.start_child(@name, [type, user_id])
  end
end
