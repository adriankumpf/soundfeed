defmodule SoundcloudRss do
  defdelegate get_likes, to: SoundcloudRss.Worker
  defdelegate save_feed, to: SoundcloudRss.Worker
  defdelegate get_feed, to: SoundcloudRss.Worker
end
