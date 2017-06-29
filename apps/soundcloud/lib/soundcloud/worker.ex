defmodule Soundcloud.Worker do
  use GenServer

  require Logger

  alias Soundcloud.Worker.Behavior

  @refresh_rate 3*60*60*1000
  @lifetime 11.95*60*60*1000 |> trunc
  @max_retries 5

  ### Public API

  def start_link(type, user_id) do
    case :global.whereis_name({type, user_id}) do
      :undefined ->
        start_and_fetch(type, user_id)
      pid ->
        {:ok, pid}
    end
  end

  def get_tracks(type, user_id), do:
    GenServer.call({:global, {type, user_id}}, :get_tracks)

  def get_feed(type, user_id), do:
    GenServer.call({:global, {type, user_id}}, :get_feed)

  def get_user(type, user_id), do:
    GenServer.call({:global, {type, user_id}}, :get_user)

  ### Server API

  def init(user_id) do
    schedule_refresh()
    schedule_expiration()

    case Behavior.init(user_id) do
      {:ok, data} -> {:ok, {data, @max_retries}}
      {:error, reason} -> {:stop, reason}
    end
  end

  def handle_info(:fetch_and_save_feed, {_, retries_left} = state) when retries_left <= 0, do:
    {:stop, :too_many_failed_retries, state}
  def handle_info(:fetch_and_save_feed, {data, retries_left}) do
    case apply(Behavior, :fetch, [data]) do
      {:ok, newData} ->
        case Behavior.save_feed(newData) do
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
    {:reply, Behavior.get_tracks(data), state}
  def handle_call(:get_feed, _from, {data, _} = state), do:
    {:reply, Behavior.get_feed(data), state}
  def handle_call(:get_user, _from, {data, _} = state), do:
    {:reply, Behavior.get_user(data), state}

  ### Private

  defp start_and_fetch(type, user_id) do
    case GenServer.start_link(__MODULE__, {type, user_id}) do
      ok = {:ok, pid} ->
        :yes = :global.register_name({type, user_id}, pid)
        ok
      err = {:error, _} ->
        err
    end
  end

  defp schedule_refresh(), do:
    Process.send_after(self(), :refresh, @refresh_rate)

  defp schedule_expiration(), do:
    Process.send_after(self(), :expire, @lifetime)

  defp schedule_retry(task, retries_left) do
    wait_before_retry = @max_retries - retries_left + 1
    Logger.error("#{task} failed. retrying in #{wait_before_retry} minute(s) ...")
    Process.send_after(self(), task, wait_before_retry*60*1000)
  end
end
