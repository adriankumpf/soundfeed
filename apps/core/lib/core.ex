defmodule Core do
  defdelegate new(type, user_id), to: Core.Supervisor

  defdelegate get_tracks(type, user_id), to: Core.Worker
  defdelegate get_feed(type, user_id), to: Core.Worker
  defdelegate get_user(type, user_id), to: Core.Worker

  defdelegate lookup(user), to: Core.LookupWorker
end
