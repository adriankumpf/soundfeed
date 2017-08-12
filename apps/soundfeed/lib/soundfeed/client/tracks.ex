defmodule Soundfeed.Client.Tracks do
  use Soundfeed.Client.API

  def url(user_id), do: "https://api.soundcloud.com/users/#{user_id}/tracks"
end
