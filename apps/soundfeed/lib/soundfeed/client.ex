defmodule Soundfeed.Client do
  alias Soundfeed.Client.{ Resolver, Reposts, Tracks, Likes, User }

  def fetch(:reposts, user_id), do: Reposts.fetch(user_id)
  def fetch(:tracks, user_id), do: Tracks.fetch(user_id)
  def fetch(:likes, user_id), do: Likes.fetch(user_id)
  def fetch(:user, user_id), do: User.fetch(user_id)

  def lookup(user), do: Resolver.lookup(user)
end
