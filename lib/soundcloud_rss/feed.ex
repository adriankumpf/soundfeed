defmodule SoundcloudRss.Feed do

  alias SoundcloudRss.Feed.{RSS, Helper}
  alias SoundcloudRss.Models.Like

  @title "addison's likes"
  @url "https://soundcloud.com/addison-359429960/likes"
  @desc "All tracks you've liked"

  def build(likes) do
    channel = RSS.channel(@title, @url, @desc, Helper.now_rfc1123())
    items = Enum.map(likes, &create_item/1)
    RSS.feed(channel, items)
  end

  defp create_item(%Like{ id: id, title: title, description: desc, permalink_url: url}) do
    RSS.item(title, desc, url, url)
  end
end
