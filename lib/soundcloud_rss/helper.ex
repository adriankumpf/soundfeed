defmodule SoundcloudRss.Helper do
  def now_rfc1123 do
    :erlang.localtime
    |> :httpd_util.rfc1123_date
  end
end
