defmodule SoundFeed.Api.Resolver do
  require Logger

  alias Plug.Conn.Status
  alias SoundFeed.Api

  def lookup(user, opts \\ []) do
    Logger.info("Looking up '#{user}'", notify: true)

    params = [
      url: "http://soundcloud.com/#{user}",
      client_id: opts[:client_id]
    ]

    case Api.get("/resolve", query: params) do
      {:ok, %Tesla.Env{status: 302} = env} -> find_user_id(env)
      {:ok, %Tesla.Env{status: status}} -> {:error, Status.reason_atom(status)}
      {:error, e} when is_exception(e) -> {:error, Exception.message(e)}
      {:error, reason} -> {:error, reason}
    end
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
end
