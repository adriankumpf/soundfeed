defmodule SoundfeedCore.Worker.Server do
  use GenServer

  alias SoundfeedCore.Worker.{Helpers, Impl}

  require Logger
  import Helpers

  @refresh_rate 3 |> :timer.hours() |> randomize(0.063)
  @lifetime 48 |> :timer.hours() |> randomize(0.12)
  @max_retries 5

  def init(args) do
    schedule_refresh()
    schedule_expiration()

    _ = Logger.info(fn -> "Startinging Worker #{inspect(args)}" end)

    case Impl.init(args) do
      {:ok, data} -> {:ok, {data, @max_retries}}
      {:error, reason} -> {:stop, reason}
    end
  end

  def handle_info(:fetch_and_save_feed, {_, retries_left} = state)
      when retries_left <= 0 do
    {:stop, :too_many_failed_retries, state}
  end

  def handle_info(:fetch_and_save_feed, {data, retries_left}) do
    case Impl.fetch(data) do
      {:ok, new_data} ->
        case Impl.save_feed(new_data) do
          {:ok, _} -> {:noreply, {new_data, @max_retries}}
          {:error, err} -> {:stop, err, :saving_feed_failed}
        end

      {:error, reason} ->
        _ = Logger.error("Fetching failed: #{inspect(reason)}")
        retries_left = retries_left - 1
        schedule_retry(:fetch_and_save_feed, retries_left)
        {:noreply, {data, retries_left}}
    end
  end

  def handle_info(:refresh, state) do
    send(self(), :fetch_and_save_feed)
    schedule_refresh()
    {:noreply, state}
  end

  def handle_info(:expire, _state), do: {:stop, :normal, nil}

  def handle_call(:get_tracks, _, {data, _} = state), do: {:reply, Impl.get_tracks(data), state}
  def handle_call(:get_feed, _, {data, _} = state), do: {:reply, Impl.get_feed(data), state}
  def handle_call(:get_user, _, {data, _} = state), do: {:reply, Impl.get_user(data), state}
  def handle_call(:get_type, _, {data, _} = state), do: {:reply, Impl.get_type(data), state}

  ### Private

  defp schedule_refresh, do: Process.send_after(self(), :refresh, @refresh_rate)

  defp schedule_expiration, do: Process.send_after(self(), :expire, @lifetime)

  defp schedule_retry(task, retries_left) do
    wait_before_retry = @max_retries - retries_left
    _ = Logger.error("Retrying: #{task} in #{wait_before_retry} minute(s)")
    Process.send_after(self(), task, :timer.minutes(wait_before_retry))
  end
end
