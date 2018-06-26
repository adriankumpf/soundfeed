defmodule SoundfeedCore.Client.User do
  use SoundfeedCore.Client.API

  alias SoundfeedCore.Client.API
  alias SoundfeedCore.Models.User

  @impl API
  def url(user_id), do: "https://api.soundcloud.com/users/#{user_id}"

  @impl API
  def body, do: %User{}
end
