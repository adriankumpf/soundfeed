defmodule SoundfeedCore.Client do

  alias SoundfeedCore.Models.{ Track, User }
  alias SoundfeedCore.Client

  @type type :: (:reposts | :tracks | :likes | :user)

  @spec fetch(type, User.id) :: {:error, any} | {:ok, [Track.t] | User.t}
  def fetch(:reposts, user_id), do: Client.Reposts.fetch(user_id)
  def fetch(:tracks, user_id), do: Client.Tracks.fetch(user_id)
  def fetch(:likes, user_id), do: Client.Likes.fetch(user_id)
  def fetch(:user, user_id), do: Client.User.fetch(user_id)

  @spec lookup(String.t) :: {:error, any} | {:ok, User.id}
  def lookup(user), do: Client.Resolver.lookup(user)
end
