defmodule Soundcloud.Client.Tracks do
  use Soundcloud.Client.API

  def url(user_id), do: "https://api.soundcloud.com/users/#{user_id}/tracks"
end
