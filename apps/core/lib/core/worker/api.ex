defmodule Core.Worker.Api do
  alias HTTPoison.Response, as: Res
  alias HTTPoison.Error, as: Err

  alias Core.Worker.Schema.{Page, Track, User}

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
    tracks
    |> Enum.reduce([], fn
      %{"track" => track}, acc -> [track | acc]
      _, acc -> acc
    end)
    |> Enum.reverse()
  end

  def normalize(data, _type), do: data

  defp get(url, type, params, acc \\ []) do
    with {:ok, json} <- HTTPoison.get(url, [], params: params) |> extract(),
         {:ok, data} <- Poison.decode(json, as: body(type)) do
      paginate(data, type, params, acc)
    end
  end

  defp extract({:ok, %Res{status_code: 200, body: body}}), do: {:ok, body}
  defp extract({:ok, %Res{status_code: 401}}), do: {:error, :forbidden}
  defp extract({:ok, %Res{body: reason}}), do: {:error, reason}
  defp extract({:error, %Err{reason: reason}}), do: {:error, reason}

  defp paginate(%User{} = user, _type, _params, _acc), do: {:ok, user}
  defp paginate(%Page{collection: c, next_href: nil}, _, _, acc), do: {:ok, acc ++ c}
  defp paginate(%Page{collection: c, next_href: url}, t, p, a), do: get(url, t, p, a ++ c)
end
