defmodule SoundcloudRss.Feed do

  alias SoundcloudRss.Models.Favorit
  alias SoundcloudRss.Feed.RSS
  alias SoundcloudRss.Helper

  @title "addison's likes"
  @url "https://soundcloud.com/addison-359429960/likes"
  @desc "All tracks you've liked"

  def build(favorites) do
    channel = RSS.channel(@title, @url, @desc, Helper.now_rfc1123(), "en-us")
    items = Enum.map(favorites, &create_item/1)
    RSS.feed(channel, items)
  end

  defp create_item(%Favorit{ id: id, title: title, description: desc,
                             permalink_url: url, liked_at: date}) do
    RSS.item(title, desc, date, url, id)
  end
end
