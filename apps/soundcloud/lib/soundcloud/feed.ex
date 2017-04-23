defmodule Soundcloud.Feed do

  alias Soundcloud.Feed.{RSS, Helper}
  alias Soundcloud.Models.Like

  @title "addison's likes"
  @url "https://soundcloud.com/addison-359429960/likes"
  @desc "All tracks you've liked"

  def build(likes) do
    channel = RSS.channel(@title, @url, @desc, Helper.now_rfc1123())
    items = Enum.map(likes, &create_item/1)
    RSS.feed(channel, items)
  end

  defp create_item(%Like{title: title, description: desc, permalink_url: url}) do
    RSS.item(title, desc, url, url)
  end
end
