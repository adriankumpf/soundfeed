defmodule Core.Controller do
  use DynamicSupervisor

  @name __MODULE__

  alias __MODULE__.Worker

  # API

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: @name)
  end

  def new(type, user_id) do
    DynamicSupervisor.start_child(@name, {Worker, {type, user_id}})
  end

  def get_report do
    DynamicSupervisor.which_children(@name)
    |> Enum.map(fn {_id, pid, _type, _modules} ->
      {:ok, summary} = Worker.get_summary(pid)
      summary
    end)
  end

  # Callbacks

  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
