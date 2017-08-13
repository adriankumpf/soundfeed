defmodule SoundfeedCore.Client.User do
  use SoundfeedCore.Client.API

  alias SoundfeedCore.Models.User
  alias SoundfeedCore.Client.API

  @impl API
  def url(user_id), do: "https://api.soundcloud.com/users/#{user_id}"

  @impl API
  def body, do: %User{}
end
