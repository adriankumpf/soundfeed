defmodule SoundFeed.Worker.Api do
  require Logger

  alias SoundFeed.Worker.Schema.{Page, Track, User}
  alias SoundFeed.HTTP
  alias Finch.Response

  def fetch(type, user_id, client_id) do
    url = url(user_id, type)

    opts = [
      linked_partitioning: 1,
      client_id: client_id,
      limit: 200
    ]

    get(url, type, opts)
  end

  def url(user_id, :likes), do: "https://api.soundcloud.com/users/#{user_id}/favorites"
  def url(user_id, :reposts), do: "https://api-v2.soundcloud.com/stream/users/#{user_id}/reposts"
  def url(user_id, :tracks), do: "https://api.soundcloud.com/users/#{user_id}/tracks"
  def url(user_id, :user), do: "https://api.soundcloud.com/users/#{user_id}"

  defp get(url, type, params, acc \\ []) do
    with {:ok, json} <- get_json(url, params),
         {:ok, data} <- decode(json, type) do
      paginate(data, type, params, acc)
    end
  end

  defp get_json(url, params) do
    url = append_query_params(url, params)

    case HTTP.get(url, receive_timeout: 15_000) do
      {:ok, %Response{status: 200, body: body}} -> {:ok, body}
      {:ok, %Response{status: 401}} -> {:error, :forbidden}
      {:ok, %Response{status: 403}} -> {:error, :forbidden}
      {:ok, %Response{status: 404}} -> {:error, :not_found}
      {:ok, %Response{body: reason}} -> {:error, reason}
      {:error, reason} -> {:error, Exception.message(reason)}
    end
  end

  defp decode(json, type) do
    case {type, Jason.decode(json)} do
      {:reposts, {:ok, %{"collection" => collection} = data}} ->
        track_collection =
          Enum.flat_map(collection, fn
            %{"type" => "track-repost", "track" => track} ->
              [Track.into(track)]

            %{"type" => "playlist-repost", "playlist" => %{"tracks" => tracks}} ->
              Enum.map(tracks, &Track.into/1)

            unknown ->
              Logger.warning("Received unknown repost type: #{inspect(unknown, pretty: true)}}")
              []
          end)

        {:ok, %Page{collection: track_collection, next_href: data["next_href"]}}

      {type, {:ok, %{"collection" => collection} = data}} when type in [:likes, :tracks] ->
        track_collection = Enum.map(collection, &Track.into/1)
        {:ok, %Page{collection: track_collection, next_href: data["next_href"]}}

      {:user, {:ok, user}} ->
        {:ok, User.into(user)}

      {_type, {:error, reason}} ->
        {:error, reason}
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
