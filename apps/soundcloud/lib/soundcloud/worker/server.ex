defmodule Soundcloud.Worker.Server do
  use GenServer

  alias Soundcloud.Worker.{Helpers, Impl}

  require Logger
  import Helpers

  @refresh_rate 3*60*60*1000 |> randomize(0.05)
  @lifetime    12*60*60*1000 |> randomize(0.20)
  @max_retries 5

  def init(user_id) do
    schedule_refresh()
    schedule_expiration()

    case Impl.init(user_id) do
      {:ok, data} -> {:ok, {data, @max_retries}}
      {:error, reason} -> {:stop, reason}
    end
  end

  def handle_info(:fetch_and_save_feed, {_, retries_left} = state) when retries_left <= 0, do:
    {:stop, :too_many_failed_retries, state}
  def handle_info(:fetch_and_save_feed, {data, retries_left}) do
    case Impl.fetch(data) do
      {:ok, newData} ->
        case Impl.save_feed(newData) do
          {:ok, _} -> {:noreply, {newData, @max_retries}}
          {:error, err} -> {:stop, err, :saving_feed_failed}
        end
      {:error, _} ->
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
  def handle_info(:expire, _state), do:
    {:stop, :normal, nil}

  def handle_call(:get_tracks, _from, {data, _} = state), do:
    {:reply, Impl.get_tracks(data), state}
  def handle_call(:get_feed, _from, {data, _} = state), do:
    {:reply, Impl.get_feed(data), state}
  def handle_call(:get_user, _from, {data, _} = state), do:
    {:reply, Impl.get_user(data), state}

  ### Private

  defp schedule_refresh(), do:
    Process.send_after(self(), :refresh, @refresh_rate)

  defp schedule_expiration(), do:
    Process.send_after(self(), :expire, @lifetime)

  defp schedule_retry(task, retries_left) do
    wait_before_retry = @max_retries - retries_left
    Logger.error("#{task} failed. Retrying in #{wait_before_retry} minute(s)")
    Process.send_after(self(), task, wait_before_retry*60*1000)
  end
end
