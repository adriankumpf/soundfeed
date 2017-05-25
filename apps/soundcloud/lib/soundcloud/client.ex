defmodule Soundcloud.Client do

  alias Soundcloud.Client.Likes
  alias Soundcloud.Client.Reposts

  def fetch(:reposts, user_id), do: Reposts.fetch(user_id)
  def fetch(:likes, user_id), do: Likes.fetch(user_id)
end
