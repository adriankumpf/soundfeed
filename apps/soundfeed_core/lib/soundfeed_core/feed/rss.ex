defmodule SoundfeedCore.Feed.RSS do
  @type feed :: String.t()
  @type item :: String.t()
  @type channel :: String.t()

  @spec feed(channel, [item]) :: feed
  def feed(channel, items) do
    """
    <?xml version="1.0" encoding="utf-8"?>
    <rss version="2.0">
      <channel>
        #{channel}
        #{Enum.join(items, "")}
      </channel>
    </rss>
    """
  end

  @spec item(String.t(), String.t(), String.t(), String.t()) :: item
  def item(title, desc, link, guid) do
    """
    <item>
      <title><![CDATA[#{title}]]></title>
      <description><![CDATA[#{desc}]]></description>
      <link>#{link}</link>
      <guid>#{guid}</guid>
    </item>
    """
  end

  @spec channel(String.t(), String.t(), String.t(), String.t()) :: channel
  def channel(title, link, desc, date) do
    """
      <title>#{title}</title>
      <link>#{link}</link>
      <description>#{desc}</description>
      <lastBuildDate>#{date}</lastBuildDate>
    """
  end
end
