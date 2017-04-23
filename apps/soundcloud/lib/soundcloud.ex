defmodule Soundcloud do
  defdelegate get_likes, to: Soundcloud.Worker
  defdelegate get_feed, to: Soundcloud.Worker
end
