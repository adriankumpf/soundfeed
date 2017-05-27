defmodule Soundcloud.Client.User do
  use Soundcloud.Client.API

  alias Soundcloud.Models.User

  def url(user_id), do: "https://api.soundcloud.com/users/#{user_id}"
  def body, do: %User{}
end
