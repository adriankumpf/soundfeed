defmodule SoundfeedCore.Client.Likes do
  use SoundfeedCore.Client.API

  alias SoundfeedCore.Client.API

  @impl API
  def url(user_id), do: "https://api.soundcloud.com/users/#{user_id}/favorites"
end
