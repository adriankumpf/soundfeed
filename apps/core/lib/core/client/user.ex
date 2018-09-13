defmodule Core.Client.User do
  use Core.Client.API

  alias Core.Client.API
  alias Core.Schemas.User

  @impl API
  def url(user_id), do: "https://api.soundcloud.com/users/#{user_id}"

  @impl API
  def body, do: %User{}
end
