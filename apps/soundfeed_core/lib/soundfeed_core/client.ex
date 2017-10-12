defmodule SoundfeedCore.Client do

  alias SoundfeedCore.Client.{Reposts, Tracks, Likes, User, Resolver}
  alias SoundfeedCore.Models.User, as: UserM
  alias SoundfeedCore.Models.Track

  @type type :: (:reposts | :tracks | :likes | :user)
  @type id :: String.t

  @spec fetch(type, UserM.id, id) :: {:error, any} | {:ok, [Track.t] | UserM.t}
  def fetch(:reposts, user_id, client_id), do: Reposts.fetch(user_id, client_id)
  def fetch(:tracks, user_id, client_id), do: Tracks.fetch(user_id, client_id)
  def fetch(:likes, user_id, client_id), do: Likes.fetch(user_id, client_id)
  def fetch(:user, user_id, client_id), do: User.fetch(user_id, client_id)

  @spec lookup(String.t, id) :: {:error, any} | {:ok, UserM.id}
  def lookup(user, client_id), do: Resolver.lookup(user, client_id)
end
