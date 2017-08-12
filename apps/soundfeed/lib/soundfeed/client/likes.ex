defmodule Soundfeed.Client.Likes do
  use Soundfeed.Client.API

  def url(user_id), do: "https://api.soundcloud.com/users/#{user_id}/favorites"
end
