defmodule SoundFeed.Controller do
  use DynamicSupervisor

  alias SoundFeed.Worker

  @name __MODULE__

  # API

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: @name)
  end

  def monitor_likes(user_id) do
    with {:ok, _pid} <- start_child(:likes, user_id), do: :ok
  end

  def monitor_tracks(user_id) do
    with {:ok, _pid} <- start_child(:tracks, user_id), do: :ok
  end

  def get_report do
    DynamicSupervisor.which_children(@name)
    |> Enum.map(fn {_id, pid, _type, _modules} ->
      {:ok, summary} = Worker.get_summary(pid)
      summary
    end)
  end

  @impl true
  def init(opts) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      max_children: 1024,
      extra_arguments: [opts]
    )
  end

  defp start_child(type, user_id) do
    DynamicSupervisor.start_child(@name, {Worker, type: type, user_id: user_id})
  end
end
