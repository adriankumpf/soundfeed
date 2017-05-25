defmodule Soundcloud.Feed do

  alias Soundcloud.Feed.{RSS, Helper}
  alias Soundcloud.Models.Track

  @desc """
    Generated by soundcloud-rss:
    https://github.com/adriankumpf/soundcloud-rss
  """

  def build(tracks, type, user_id) do
    user_name = user_name(user_id)
    url = profile_page(user_id)
    now = Helper.now_rfc1123()

    channel = RSS.channel(user_name, url, @desc, now)
    items = Enum.map(tracks, &create_item/1)

    RSS.feed(channel, items)
  end

  defp create_item(%Track{title: title, description: desc, permalink_url: url}) do
    RSS.item(title, desc, url, url)
  end

  defp user_name(user_id) do
    user_id
    |> prettify
    |> String.trim
  end

  defp prettify(str) when is_bitstring(str),
    do: str |> to_charlist |> prettify |> to_string
  defp prettify([]), do: ''
  defp prettify([?- | rest]), do: ' ' ++ prettify(rest)
  defp prettify([n | rest]) when n in ?0..?9, do: prettify(rest)
  defp prettify([c | rest]), do: [c] ++ prettify(rest)

  defp profile_page(user_id) do
    "https://soundcloud.com/#{user_id}"
  end
end
