defmodule Soundcloud do
  defdelegate get_likes(user_id), to: Soundcloud.Worker
  defdelegate get_feed(user_id), to: Soundcloud.Worker
  defdelegate start(user_id), to: Soundcloud.Supervisor, as: :start_worker
end
