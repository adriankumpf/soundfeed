defmodule SoundfeedCore.Supervisor do
  use Supervisor

  @name __MODULE__

  def start_link([]), do: Supervisor.start_link(__MODULE__, [], name: @name)

  def init([]), do: Supervisor.init([SoundfeedCore.Worker], strategy: :simple_one_for_one)

  def new(type, user_id), do: Supervisor.start_child(@name, [type, user_id])
end
