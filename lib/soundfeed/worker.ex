defmodule SoundFeed.Worker do
  use GenServer, restart: :transient

  require Logger

  alias __MODULE__.{Api, Feed}

  @timeout 15_000
  @max_failures 5

  defstruct client_id: nil,
            type: nil,
            user: nil,
            tracks: %{},
            failures: 0,
            feeds_dir: nil

  alias __MODULE__, as: State

  # API

  def start_link(opts, identifier) do
    case :global.whereis_name(identifier) do
      :undefined ->
        GenServer.start_link(__MODULE__, opts ++ identifier, name: {:global, identifier})

      pid ->
        {:ok, pid}
    end
  end

  def get_summary(name) do
    GenServer.call(name, :get_summary)
  end

  # Callbacks

  @impl true
  def init(opts) do
    type = Keyword.fetch!(opts, :type)
    user_id = Keyword.fetch!(opts, :user_id)

    client_id = Keyword.fetch!(opts, :client_id)
    feeds_dir = Keyword.fetch!(opts, :feeds_dir)

    schedule_refresh()
    schedule_expiration()

    t_user = Task.async(fn -> Api.fetch(:user, user_id, client_id) end)
    t_tracks = Task.async(fn -> Api.fetch(type, user_id, client_id) end)

    with {:ok, user} <- Task.await(t_user, @timeout),
         {:ok, tracks} <- Task.await(t_tracks, @timeout) do
      Logger.info("Starting Worker: #{user_id} | #{user.username} | #{type}")

      save_feed!(type, tracks, user, feeds_dir)

      state = %State{
        client_id: client_id,
        type: type,
        user: user,
        tracks: tracks,
        feeds_dir: feeds_dir
      }

      {:ok, state}
    else
      {:error, reason} ->
        Logger.warn("Could not start Worker {#{user_id}, #{type}}: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  @impl true
  def handle_call(:get_summary, _from, %State{user: user, type: type, tracks: tracks} = state) do
    {:reply, {:ok, "#{user.username}: #{length(tracks)} #{type} [#{user.permalink_url}]"}, state}
  end

  @impl true
  def handle_info(:refresh, %State{client_id: cid, type: t, user: u, failures: failures} = state)
      when failures < @max_failures do
    case Api.fetch(t, u.id, cid) do
      {:ok, tracks} ->
        save_feed!(t, tracks, u, state.feeds_dir)

        schedule_refresh()

        {:noreply, %State{state | tracks: tracks, failures: 0}, :hibernate}

      {:error, reason} ->
        Logger.bare_log(
          if(failures > 0, do: :warn, else: :info),
          "Fetching failed: #{inspect(reason)}"
        )

        wait = :math.pow(2, failures)

        Logger.info("Retrying in #{wait} minute(s)")
        Process.send_after(self(), :refresh, round(:timer.minutes(wait)))

        {:noreply, %State{state | failures: failures + 1}}
    end
  end

  def handle_info(:refresh, state) do
    {:stop, :too_many_failures, state}
  end

  def handle_info(:expire, state) do
    {:stop, :normal, state}
  end

  # Private

  defp schedule_refresh do
    Process.send_after(self(), :refresh, :timer.minutes(90) |> randomize(0.063))
  end

  defp schedule_expiration do
    Process.send_after(self(), :expire, :timer.hours(96) |> randomize(0.12))
  end

  defp save_feed!(type, tracks, user, feeds_dir) do
    path = "#{feeds_dir}/#{user.id}"
    content = Feed.build(tracks, type, user)

    File.mkdir_p!(path)
    File.write!("#{path}/#{type}.rss", content)
  end

  defp randomize(val, factor) do
    m = trunc(val * factor)
    val + (:rand.uniform(2 * m + 1) - m - 1)
  end
end