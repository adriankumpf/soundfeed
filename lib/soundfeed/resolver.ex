defmodule SoundFeed.Resolver do
  use GenServer
  use Tesla

  adapter Tesla.Adapter.Finch, name: SoundFeed.Api, receive_timeout: 15_000

  plug Tesla.Middleware.BaseUrl, "https://api.soundcloud.com"
  plug Tesla.Middleware.Headers, [{"user-agent", "github.com/adriankumpf/soundfeed"}]
  plug Tesla.Middleware.Logger, debug: true, log_level: &log_level/1

  require Logger
  alias Plug.Conn.Status

  @name __MODULE__

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, @name))
  end

  def lookup(name \\ @name, user) do
    GenServer.call(name, {:lookup, user})
  end

  @impl GenServer
  def init(opts) do
    {:ok, %{client_id: Keyword.fetch!(opts, :client_id)}}
  end

  @impl GenServer
  def handle_call({:lookup, user}, _from, %{client_id: client_id} = state) do
    Logger.info("Looking up '#{user}'", notify: true)

    response =
      case get("/resolve", query: [url: "http://soundcloud.com/#{user}", client_id: client_id]) do
        {:ok, %Tesla.Env{status: 302} = env} -> find_user_id(env)
        {:ok, %Tesla.Env{status: status}} -> {:error, Status.reason_atom(status)}
        {:error, e} when is_exception(e) -> {:error, Exception.message(e)}
        {:error, reason} -> {:error, reason}
      end

    {:reply, response, state}
  end

  defp find_user_id(%Tesla.Env{} = env) do
    try do
      env
      |> Tesla.get_header("location")
      |> (fn "https://api.soundcloud.com/users/" <> user_id -> user_id end).()
      |> String.split("?")
      |> List.first()
    rescue
      _ -> {:error, :invalid_loaction}
    else
      user_id -> {:ok, user_id}
    end
  end

  defp log_level(%Tesla.Env{} = env) when env.status >= 400, do: :error
  defp log_level(%Tesla.Env{}), do: :info
end
