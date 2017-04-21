defmodule SoundcloudRss.Client do

  alias SoundcloudRss.Models.PagedResponse, as: PR
  alias SoundcloudRss.Models.Favorit

  @client_id Application.get_env(:soundcloud_rss, :client_id)

  def fetch_favorites(userId) do
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
    Poison.decode!(body, as: %Page{collection: [%Favorit{}]})
  end

  defp paginate(%Page{collection: col, next_href: nil}), do: col
  defp paginate(%Page{collection: col, next_href: url}), do: col ++ get(url)
end
