defmodule Core.Reporter do
  use GenServer

  require Logger

  alias Core.Schemas.User
  alias Core.Controller

  @name __MODULE__

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @name)
  end

  def generate do
    Process.send(__MODULE__, :schedule_report, [])
  end

  # Callbacks

  def init(_args) do
    send(self(), :schedule_report)
    {:ok, nil}
  end

  @impl true
  def handle_continue(:schedule_report, %State{timer: old_timer} = state) do
    {:noreply, %State{state | timer: send_report(old_timer)}, :hibernate}
  end

  @impl true
  def handle_info(:schedule_report, %State{timer: old_timer} = state) do
    {:noreply, %State{state | timer: send_report(old_timer)}, :hibernate}
  end

  # Private

  defp send_report(old_timer) do
    reports =
      Controller.get_report()
      |> Enum.map(fn {%User{username: name}, type, tracks} ->
        "#{name}: #{tracks} #{type}"
      end)
      |> Enum.sort()

    _ = Logger.info("Running workers:\n#{report}", notify: true)

    _ = cancel_timer(old_timer)
    timer = Process.send_after(self(), :schedule_report, ms_until_next_report())

    {:noreply, timer}
  end

  # Private

  defp cancel_timer(nil), do: 0
  defp cancel_timer(timer), do: Process.cancel_timer(timer)

  defp ms_until_next_report do
    Timex.now()
    |> Timex.end_of_week()
    |> Timex.diff(Timex.now(), :milliseconds)
  end
end
