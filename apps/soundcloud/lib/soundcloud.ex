defmodule Soundcloud do
  defdelegate get_tracks(type, user_id), to: Soundcloud.Worker
  defdelegate get_feed(type, user_id), to: Soundcloud.Worker
  defdelegate start(type, user_id), to: Soundcloud.Supervisor, as: :start_worker
end
