defmodule SoundFeed.Worker.Api do
  alias Finch.Response

  alias SoundFeed.Worker.Schema.{Page, Track, User}
  alias SoundFeed.HTTP

  def fetch(type, user_id, client_id) do
    url = url(user_id, type)

    opts = [
      linked_partitioning: 1,
      client_id: client_id,
      limit: 200
    ]

    with {:ok, response} <- get(url, type, opts) do
      {:ok, normalize(response, type)}
    end
  end

  def url(user_id, :likes), do: "https://api.soundcloud.com/users/#{user_id}/favorites"
  def url(user_id, :reposts), do: "https://api-v2.soundcloud.com/stream/users/#{user_id}/reposts"
  def url(user_id, :tracks), do: "https://api.soundcloud.com/users/#{user_id}/tracks"
  def url(user_id, :user), do: "https://api.soundcloud.com/users/#{user_id}"

  def body(:reposts), do: %Page{collection: [%{"track" => %Track{}}]}
  def body(:user), do: %User{}
  def body(_), do: %Page{collection: [%Track{}]}

  def normalize(tracks, :reposts) do
    Enum.flat_map(tracks, fn
      %{"track" => track} -> [track]
      _ -> []
    end)
  end

  def normalize(data, _type), do: data

  defp get(url, type, params, acc \\ []) do
    with {:ok, json} <- get_json(url, params),
         {:ok, data} <- Poison.decode(json, as: body(type)) do
      paginate(data, type, params, acc)
    end
  end

  defp get_json(url, params) do
    url = append_query_params(url, params)

    case HTTP.get(url, receive_timeout: 15_000) do
      {:ok, %Response{status: 200, body: body}} -> {:ok, body}
      {:ok, %Response{status: 401}} -> {:error, :forbidden}
      {:ok, %Response{status: 404}} -> {:error, :not_found}
      {:ok, %Response{body: reason}} -> {:error, reason}
      {:error, reason} -> {:error, Exception.message(reason)}
    end
  end

  defp paginate(%User{} = user, _type, _params, _acc), do: {:ok, user}
  defp paginate(%Page{collection: c, next_href: nil}, _, _, acc), do: {:ok, acc ++ c}
  defp paginate(%Page{collection: c, next_href: url}, t, p, a), do: get(url, t, p, a ++ c)

  defp append_query_params(url, params) do
    url
    |> URI.parse()
    |> Map.update!(:query, fn
      nil ->
        URI.encode_query(params)

      query ->
        query
        |> URI.decode_query()
        |> Map.merge(Enum.into(params, %{}))
        |> URI.encode_query()
    end)
    |> URI.to_string()
  end
end
