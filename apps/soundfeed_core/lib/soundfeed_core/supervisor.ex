defmodule SoundfeedCore.Supervisor do
  use Supervisor

  @name __MODULE__

  # API

  def start_link([]) do
    Supervisor.start_link(__MODULE__, [], name: @name)
  end

  def new(type, user_id) do
    Supervisor.start_child(@name, [type, user_id])
  end

  def get_report do
    @name
    |> Supervisor.which_children()
    |> Enum.map(fn {_id, child, _type, _modules} ->
      %SoundfeedCore.Models.User{username: name} = GenServer.call(child, :get_user)
      tracks = child |> GenServer.call(:get_tracks) |> Map.values |> length
      type = GenServer.call(child, :get_type)

      {name, type, tracks}
    end)
  end

  # Callbacks

  def init([]) do
    Supervisor.init([SoundfeedCore.Worker], strategy: :simple_one_for_one)
  end
end
