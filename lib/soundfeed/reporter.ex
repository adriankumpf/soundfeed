defmodule SoundFeed.Reporter do
  use GenServer

  require Logger

  alias SoundFeed.Controller

  defstruct timer: nil
  alias __MODULE__, as: State

  @name __MODULE__

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @name)
  end

  def send_report do
    GenServer.cast(@name, :send_report)
  end

  # Callbacks

  @impl true
  def init(_opts) do
    {:ok, %State{}, {:continue, :schedule_report}}
  end

  @impl true
  def handle_cast(:send_report, state) do
    {:noreply, state, {:continue, :schedule_report}}
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
      |> Enum.sort()

    Logger.info("Running workers [#{length(reports)}]:\n#{Enum.join(reports, "\n")}",
      notify: true
    )

    cancel_timer(old_timer)
    timer = Process.send_after(self(), :schedule_report, ms_until_next_report())

    timer
  end

  defp cancel_timer(nil), do: :ok
  defp cancel_timer(timer), do: Process.cancel_timer(timer)

  defp ms_until_next_report do
    Timex.now()
    |> Timex.end_of_week()
    |> Timex.diff(Timex.now(), :milliseconds)
  end
end
