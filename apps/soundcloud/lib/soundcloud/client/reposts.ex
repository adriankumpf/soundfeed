defmodule Soundcloud.Client.Reposts do
  use Soundcloud.Client.API

  alias Soundcloud.Models.Track

  def url(user_id), do: "https://api-v2.soundcloud.com/stream/users/#{user_id}/reposts"
  def collection, do: [%{"track" => %Track{}}]
  def normalize(tracks), do: unwrap(tracks)

  defp unwrap(tracks) do
    tracks
    |> Enum.map(&mapper/1)
    |> Enum.filter(& &1)
  end

  defp mapper(%{"track" => track}), do: track
  defp mapper(_), do: nil
end
