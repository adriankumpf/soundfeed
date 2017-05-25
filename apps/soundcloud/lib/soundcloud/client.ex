defmodule Soundcloud.Client do

  alias Soundcloud.Client.Likes
  alias Soundcloud.Client.Reposts

  def fetch_reposts(userId), do: Reposts.fetch(userId)
  def fetch_likes(userId), do: Likes.fetch(userId)
end
