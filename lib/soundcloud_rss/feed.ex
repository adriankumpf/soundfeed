defmodule SoundcloudRss.Feed do

  alias SoundcloudRss.Models.Like
  alias SoundcloudRss.Feed.RSS
  alias SoundcloudRss.Helper

  @title "addison's likes"
  @url "https://soundcloud.com/addison-359429960/likes"
  @desc "All tracks you've liked"

  def build(likes) do
    channel = RSS.channel(@title, @url, @desc, Helper.now_rfc1123(), "en-us")
    items = Enum.map(likes, &create_item/1)
    RSS.feed(channel, items)
  end

  defp create_item(%Like{ id: id, title: title, description: desc,
                             permalink_url: url, liked_at: date}) do
    RSS.item(title, desc, date, url, id)
  end
end
