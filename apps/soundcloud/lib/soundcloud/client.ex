defmodule Soundcloud.Client do

  alias Soundcloud.Models.PagedResponse, as: Page
  alias Soundcloud.Models.Like

  @client_id Application.get_env(:soundcloud, :client_id)

  def fetch_likes(userId) do
    get("https://api.soundcloud.com/users/#{userId}/favorites", [
          linked_partitioning: 1,
          client_id: @client_id,
          limit: 200
        ])
  end

  def get(url, params \\ []) do
    HTTPoison.get!(url, [], params: params)
    |> parse_json
    |> paginate
  end

  defp parse_json(%HTTPoison.Response{status_code: 200, body: body}) do
    Poison.decode!(body, as: %Page{collection: [%Like{}]})
  end

  defp paginate(%Page{collection: col, next_href: nil}), do: col
  defp paginate(%Page{collection: col, next_href: url}), do: col ++ get(url)
end
