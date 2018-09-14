defmodule Core.Client do
  alias Core.Client.{Likes, Reposts, Resolver, Tracks, User}

  def fetch(:reposts, user_id, client_id), do: Reposts.fetch(user_id, client_id)
  def fetch(:tracks, user_id, client_id), do: Tracks.fetch(user_id, client_id)
  def fetch(:likes, user_id, client_id), do: Likes.fetch(user_id, client_id)
  def fetch(:user, user_id, client_id), do: User.fetch(user_id, client_id)

  def lookup(user, client_id), do: Resolver.lookup(user, client_id)
end
