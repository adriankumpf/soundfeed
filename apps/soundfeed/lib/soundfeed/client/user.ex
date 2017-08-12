defmodule Soundfeed.Client.User do
  use Soundfeed.Client.API

  alias Soundfeed.Models.User

  def url(user_id), do: "https://api.soundcloud.com/users/#{user_id}"
  def body, do: %User{}
end
