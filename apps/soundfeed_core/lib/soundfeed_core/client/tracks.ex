defmodule SoundfeedCore.Client.Tracks do
  use SoundfeedCore.Client.API

  def url(user_id), do: "https://api.soundcloud.com/users/#{user_id}/tracks"
end
