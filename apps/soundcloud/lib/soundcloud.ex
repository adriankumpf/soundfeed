defmodule Soundcloud do
  defdelegate start(type, user_id), to: Soundcloud.Supervisor, as: :start_worker
  defdelegate get_tracks(type, user_id), to: Soundcloud.Worker
  defdelegate get_feed(type, user_id), to: Soundcloud.Worker
  defdelegate lookup(user), to: Soundcloud.Client
end
