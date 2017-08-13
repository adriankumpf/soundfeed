defmodule SoundfeedCore.Client do

  alias SoundfeedCore.Client.{Reposts, Tracks, Likes, User, Resolver}
  alias SoundfeedCore.Models.User, as: UserM
  alias SoundfeedCore.Models.Track

  @type type :: (:reposts | :tracks | :likes | :user)

  @spec fetch(type, UserM.id) :: {:error, any} | {:ok, [Track.t] | UserM.t}
  def fetch(:reposts, user_id), do: Reposts.fetch(user_id)
  def fetch(:tracks, user_id), do: Tracks.fetch(user_id)
  def fetch(:likes, user_id), do: Likes.fetch(user_id)
  def fetch(:user, user_id), do: User.fetch(user_id)

  @spec lookup(String.t) :: {:error, any} | {:ok, UserM.id}
  def lookup(user), do: Resolver.lookup(user)
end
