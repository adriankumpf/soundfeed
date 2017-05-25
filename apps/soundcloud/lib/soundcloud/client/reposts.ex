defmodule Soundcloud.Client.Reposts do
  use Soundcloud.Client.API

  alias HTTPoison.Response
  alias Soundcloud.Models.Track

  @client_id Application.get_env(:soundcloud, :client_id)

  def url(user_id), do: "https://api-v2.soundcloud.com/stream/users/#{resolve(user_id)}/reposts"
  def collection, do: [%{"track" => %Track{}}]
  def normalize(tracks), do: unwrap(tracks)

  defp resolve(user_id) do
    %Response{status_code: 302, headers: headers} =
      HTTPoison.get!("http://api.soundcloud.com/resolve", [], params: [
        client_id: @client_id,
        url: "http://soundcloud.com/#{user_id}"
      ])

    headers
    |> get_location
    |> get_user_id
  end

  defp get_location([{"Location", loc} | _]), do: loc
  defp get_location([_ | headers]), do: get_location(headers)

  defp get_user_id("https://api.soundcloud.com/users/" <> user_id) do
    user_id |> String.split("?") |> hd
  end

  defp unwrap(tracks) do
    tracks
    |> Enum.map(&mapper/1)
    |> Enum.filter(& &1)
  end

  defp mapper(%{"track" => track}), do: track
  defp mapper(_), do: nil
end
