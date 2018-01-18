defmodule SoundfeedCore.Supervisor do
  use DynamicSupervisor

  @name __MODULE__

  # API

  def start_link([]) do
    DynamicSupervisor.start_link(__MODULE__, [], name: @name)
  end

  def new(type, user_id) do
    DynamicSupervisor.start_child(@name, {SoundfeedCore.Worker, [type, user_id]})
  end

  def get_report do
    @name
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn {_id, child, _type, _modules} ->
      %SoundfeedCore.Models.User{username: name} = GenServer.call(child, :get_user)
      tracks = child |> GenServer.call(:get_tracks) |> Map.values |> length
      type = GenServer.call(child, :get_type)

      {name, type, tracks}
    end)
  end

  # Callbacks

  def init([]) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
