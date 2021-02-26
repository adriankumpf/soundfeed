defmodule SoundFeed.Api do
  use Tesla

  def child_spec(_arg) do
    Finch.child_spec(name: __MODULE__, pools: %{:default => [size: 25]})
    |> Map.replace!(:id, __MODULE__)
  end

  adapter Tesla.Adapter.Finch, name: __MODULE__, receive_timeout: 15_000

  plug Tesla.Middleware.BaseUrl, "https://api.soundcloud.com"
  plug Tesla.Middleware.Headers, [{"user-agent", "github.com/adriankumpf/soundfeed"}]
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Logger, debug: true, log_level: &log_level/1

  alias SoundFeed.Schema.{Page, Track, User}

  def fetch(type, user_id, client_id) do
    get_paged(url(user_id, type), type,
      linked_partitioning: 1,
      client_id: client_id,
      limit: 200
    )
  end

  def url(user_id, :likes), do: "/users/#{user_id}/likes/tracks"
  def url(user_id, :tracks), do: "/users/#{user_id}/tracks"
  def url(user_id, :user), do: "/users/#{user_id}"

  defp get_paged(url, type, params, acc \\ []) do
    with {:ok, body} <- get_body(url, params),
         {:ok, data} <- decode(type, body) do
      paginate(data, type, params, acc)
    end
  end

  defp get_body(url, params) do
    case get(url, query: params) do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:ok, %Tesla.Env{status: 401}} -> {:error, :forbidden}
      {:ok, %Tesla.Env{status: 403}} -> {:error, :forbidden}
      {:ok, %Tesla.Env{status: 404}} -> {:error, :not_found}
      {:ok, %Tesla.Env{body: reason}} -> {:error, reason}
      {:error, e} when is_exception(e) -> {:error, Exception.message(e)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp decode(:user, user), do: {:ok, User.into(user)}

  defp decode(_type, %{"collection" => collection} = data) do
    {:ok, %Page{collection: Enum.map(collection, &Track.into/1), next_href: data["next_href"]}}
  end

  defp paginate(%User{} = user, _type, _params, _acc), do: {:ok, user}
  defp paginate(%Page{collection: c, next_href: nil}, _, _, acc), do: {:ok, acc ++ c}
  defp paginate(%Page{collection: c, next_href: url}, t, p, a), do: get_paged(url, t, p, a ++ c)

  defp log_level(%Tesla.Env{} = env) when env.status >= 400, do: :error
  defp log_level(%Tesla.Env{} = env) when env.status >= 300, do: :warn
  defp log_level(%Tesla.Env{}), do: :info
end
