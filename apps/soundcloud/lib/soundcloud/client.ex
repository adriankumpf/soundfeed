defmodule Soundcloud.Client do

  alias HTTPoison.Response

  alias Soundcloud.Models.PagedResponse, as: Page
  alias Soundcloud.Models.{ErrorMessage, Errors}
  alias Soundcloud.Models.Like

  @client_id Application.get_env(:soundcloud, :client_id)

  def fetch_likes(userId) do
    likes = get("https://api.soundcloud.com/users/#{userId}/favorites", [
                   linked_partitioning: 1,
                   client_id: @client_id,
                   limit: 200
                 ])

    case likes do
      %ErrorMessage{error_message: msg} ->
        {:error, msg}
      _ ->
        {:ok, likes}
    end
  end

  def get(url, params \\ []) do
    HTTPoison.get!(url, [], params: params)
    |> parse_json
    |> paginate
  end

  defp parse_json(%Response{status_code: 200, body: body}) do
    Poison.decode!(body, as: %Page{collection: [%Like{}]})
  end
  defp parse_json(%Response{status_code: 404, body: err}) do
    Poison.decode!(err, as: %Errors{errors: [%ErrorMessage{}]})
    |> Map.get(:errors, [])
    |> hd
  end
  defp parse_json(%Response{status_code: _, body: body}) do
    %ErrorMessage{error_message: body}
  end

  defp paginate(%Page{collection: col, next_href: nil}), do: col
  defp paginate(%Page{collection: col, next_href: url}), do: col ++ get(url)
  defp paginate(%ErrorMessage{} = error), do: error
end
