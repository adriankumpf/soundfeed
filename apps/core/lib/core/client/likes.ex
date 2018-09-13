defmodule Core.Client.Likes do
  use Core.Client.API

  alias Core.Client.API

  @impl API
  def url(user_id), do: "https://api.soundcloud.com/users/#{user_id}/favorites"
end
