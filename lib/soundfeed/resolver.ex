defmodule SoundFeed.Resolver do
  use GenServer

  require Logger

  alias SoundFeed.HTTP
  alias Finch.Response

  defstruct [:client_id]
  alias __MODULE__, as: State

  @name __MODULE__

  # API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, @name))
  end

  def lookup(name \\ @name, user) do
    GenServer.call(name, {:lookup, user})
  end

  # Callbacks

  @impl true
  def init(opts) do
    {:ok, %State{client_id: Keyword.fetch!(opts, :client_id)}}
  end

  @impl true
  def handle_call({:lookup, user}, _from, %State{client_id: client_id} = state) do
    Logger.info("Looking up '#{user}'", notify: true)

    params = [
      url: "http://soundcloud.com/#{user}",
      client_id: client_id
    ]

    url =
      URI.parse("https://api.soundcloud.com/resolve")
      |> Map.put(:query, URI.encode_query(params))
      |> URI.to_string()

    response =
      case HTTP.get(url) do
        {:ok, %Response{status: 302, headers: headers}} -> find_user_id(headers)
        {:ok, %Response{status: 404}} -> {:error, :not_found}
        {:ok, %Response{status: status}} -> {:error, {:bad_status_code, status}}
        {:error, error} -> {:error, Exception.message(error)}
      end

    {:reply, response, state}
  end

  # Private

  defp find_user_id(headers) do
    with {:ok, location} <- get_header(headers, "location"),
         {:ok, user_id} <- extract_user_id(location) do
      {:ok, user_id}
    end
  end

  defp get_header(headers, key) do
    case List.keyfind(headers, key, 0) do
      {^key, value} -> {:ok, value}
      nil -> {:error, :header_not_found}
    end
  end

  defp extract_user_id("https://api.soundcloud.com/users/" <> user_id) do
    {:ok, split_left(user_id, "?")}
  end

  defp extract_user_id(location) do
    Logger.error("Could not extract user_id from #{location}")
    {:error, :invalid_loaction}
  end

  defp split_left(string, sep) do
    case :binary.match(string, [sep]) do
      {start, _length} ->
        <<left::binary-size(start), _::binary>> = string
        left

      :nomatch ->
        string
    end
  end
end
