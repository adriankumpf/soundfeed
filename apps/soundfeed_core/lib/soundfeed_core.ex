defmodule SoundfeedCore do
  defdelegate new(type, user_id), to: SoundfeedCore.Supervisor

  defdelegate get_tracks(type, user_id), to: SoundfeedCore.Worker
  defdelegate get_feed(type, user_id), to: SoundfeedCore.Worker
  defdelegate get_user(type, user_id), to: SoundfeedCore.Worker

  defdelegate lookup(user), to: SoundfeedCore.Client
end
