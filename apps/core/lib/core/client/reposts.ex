defmodule Core.Client.Reposts do
  use Core.Client.API

  alias Core.Client.API
  alias Core.Schemas.PagedResponse, as: Page
  alias Core.Schemas.Track

  @impl API
  def url(user_id), do: "https://api-v2.soundcloud.com/stream/users/#{user_id}/reposts"

  @impl API
  def body, do: %Page{collection: [%{"track" => %Track{}}]}

  @impl API
  def normalize(tracks), do: unwrap(tracks)

  defp unwrap(tracks) do
    tracks
    |> Enum.map(&mapper/1)
    |> Enum.filter(& &1)
  end

  defp mapper(%{"track" => track}), do: track
  defp mapper(_), do: nil
end
