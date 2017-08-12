defmodule Soundfeed do
  defdelegate new(type, user_id), to: Soundfeed.Supervisor

  defdelegate get_tracks(type, user_id), to: Soundfeed.Worker
  defdelegate get_feed(type, user_id), to: Soundfeed.Worker
  defdelegate get_user(type, user_id), to: Soundfeed.Worker

  defdelegate lookup(user), to: Soundfeed.Client
end
