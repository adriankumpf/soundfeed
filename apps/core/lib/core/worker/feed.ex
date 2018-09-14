defmodule Core.Worker.Feed do
  use Timex

  alias Core.Worker.Schema.{Track, User}

  @max Application.get_env(:core, :feed_item_desc_length)
  @desc "Generated by SoundFeed: https://github.com/adriankumpf/soundfeed"

  def build(tracks, type, %User{id: id, username: name, permalink_url: user_link}) do
    """
    <?xml version="1.0" encoding="utf-8"?>
    <rss version="2.0">
      <channel>
        <title>#{name} - #{type}</title>
        <link>#{user_link}</link>
        <description>#{@desc}</description>
        <lastBuildDate>#{now()}</lastBuildDate>
    #{
      for %Track{title: title, desc: desc, permalink_url: track_link} <- tracks do
        '''
            <item>
              <title><![CDATA[#{title}]]></title>
              <description><![CDATA[#{shorten(desc, @max)}]]></description>
              <link>#{track_link}</link>
              <guid>#{track_link}?user=#{id}</guid>
            </item>
        '''
      end
      |> Enum.join()
      |> String.trim_trailing()
    }
      </channel>
    </rss>
    """
  end

  defp now, do: Timex.format!(Timex.now(), "{RFC1123}")

  defp shorten(nil, _max), do: ""
  defp shorten(str, max) when byte_size(str) <= max, do: str
  defp shorten(str, max), do: with({short, _} = String.split_at(str, max), do: short <> "...")
end
