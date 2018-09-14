defmodule Core.Controller.Worker do
  use GenServer, restart: :transient

  require Logger

  alias Core.{Feed, Client}

  import __MODULE__.Helpers

  @feeds_dir Application.get_env(:core, :feeds_dir)
  @timeout 65_000

  @refresh_rate 3 |> :timer.hours() |> randomize(0.063)
  @lifetime 48 |> :timer.hours() |> randomize(0.12)
  @max_retries 5

  defstruct client_id: nil, type: nil, user: nil, tracks: %{}, retries: @max_retries
  alias __MODULE__, as: State

  # API

  def start_link({type, user_id}) do
    case :global.whereis_name({type, user_id}) do
      :undefined ->
        GenServer.start_link(__MODULE__, {type, user_id}, name: {:global, {type, user_id}})

      pid ->
        {:ok, pid}
    end
  end

  def get_summary(name) do
    GenServer.call(name, :get_summary)
  end

  # Callbacks

  @impl true
  def init({type, user_id} = args) do
    schedule_refresh()
    schedule_expiration()

    _ = Logger.info(fn -> "Startinging Worker #{inspect(args)}" end)

    client_id = Application.get_env(:core, :client_id)

    t_user_info = Task.async(fn -> Client.fetch(:user, user_id, client_id) end)
    t_tracks = Task.async(fn -> Client.fetch(type, user_id, client_id) end)

    with {:ok, user} <- Task.await(t_user_info, @timeout),
         {:ok, tracks} <- Task.await(t_tracks, @timeout) do
      save_feed!(type, tracks, user)
      {:ok, %State{client_id: client_id, type: type, user: user, tracks: tracks}}
    else
      {:error, reason} -> {:stop, reason}
    end
  end

  @impl true
  def handle_call(:get_summary, _from, %State{user: user, type: type, tracks: tracks} = state) do
    {:reply, {:ok, {user.username, type, length(tracks)}}, state}
  end

  @impl true
  def handle_info(
        :refresh,
        %State{client_id: client_id, type: type, user: user, retries: retries} = state
      )
      when retries > 0 do
    case Client.fetch(type, user.id, client_id) do
      {:ok, tracks} ->
        {:noreply, %State{state | tracks: tracks, retries: @max_retries}, {:continue, :save}}

      {:error, reason} ->
        if retries < 4, do: Logger.error("Fetching failed: #{inspect(reason)}")

        retries = retries - 1
        wait = @max_retries - retries

        Logger.info("Retrying in #{wait} minute(s)")
        Process.send_after(self(), :refresh, :timer.minutes(wait))

        {:noreply, %State{state | retries: retries}}
    end
  end

  def handle_info(:refresh, state) do
    {:stop, :too_many_failed_retries, state}
  end

  def handle_info(:expire, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_continue(:save, %State{type: type, tracks: tracks, user: user} = state) do
    save_feed!(type, tracks, user)
    schedule_refresh()
    {:noreply, state}
  end

  # Private

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_rate)
  end

  defp schedule_expiration do
    Process.send_after(self(), :expire, @lifetime)
  end

  defp save_feed!(type, tracks, user) do
    path = "#{@feeds_dir}/#{user.id}"
    content = Feed.build(tracks, type, user)

    File.mkdir_p!(path)
    File.write!("#{path}/#{type}.rss", content)
  end
end
