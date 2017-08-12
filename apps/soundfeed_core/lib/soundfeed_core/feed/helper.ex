defmodule SoundfeedCore.Feed.Helper do
  use Timex

  def now_rfc1123 do
    {:ok, date} = Timex.format(Timex.now, "{RFC1123}")
    date
  end
end
