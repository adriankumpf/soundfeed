defmodule SoundfeedCore.Client.User do
  use SoundfeedCore.Client.API

  alias SoundfeedCore.Models.User

  def url(user_id), do: "https://api.soundcloud.com/users/#{user_id}"
  def body, do: %User{}
end
