defmodule Soundcloud do
  defdelegate new(type, user_id), to: Soundcloud.Supervisor

  defdelegate get_tracks(type, user_id), to: Soundcloud.Worker
  defdelegate get_feed(type, user_id), to: Soundcloud.Worker
  defdelegate get_user(type, user_id), to: Soundcloud.Worker

  defdelegate lookup(user), to: Soundcloud.Client
end
