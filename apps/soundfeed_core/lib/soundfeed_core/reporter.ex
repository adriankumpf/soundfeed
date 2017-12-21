defmodule SoundfeedCore.Reporter do
  use GenServer

  require Logger

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

  def handle_info(:schedule_report, old_timer) do
    report =
      SoundfeedCore.Supervisor.get_report()
      |> Enum.map(fn {user, type, tracks} ->
        "#{user}: #{tracks} #{type}"
      end)
      |> Enum.sort()
      |> Enum.join("\n")

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
