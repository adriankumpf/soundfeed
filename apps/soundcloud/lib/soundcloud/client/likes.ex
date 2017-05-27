defmodule Soundcloud.Client.Likes do
  use Soundcloud.Client.API

  alias Soundcloud.Models.Track

  def url(user_id), do: "https://api.soundcloud.com/users/#{user_id}/favorites"
end
