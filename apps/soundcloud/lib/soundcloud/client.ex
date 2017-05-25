defmodule Soundcloud.Client do

  alias Soundcloud.Client.Resolver
  alias Soundcloud.Client.Reposts
  alias Soundcloud.Client.Tracks
  alias Soundcloud.Client.Likes

  def fetch(:reposts, user_id), do: Reposts.fetch(user_id)
  def fetch(:tracks, user_id), do: Tracks.fetch(user_id)
  def fetch(:likes, user_id), do: Likes.fetch(user_id)

  def lookup(user), do: Resolver.lookup(user)
end
