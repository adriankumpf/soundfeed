defmodule Soundcloud.Client.Likes do
  use Soundcloud.Client.API

  alias Soundcloud.Models.Track

  def url(userId), do: "https://api.soundcloud.com/users/#{userId}/favorites"
  def collection, do: [%Track{}]
end
