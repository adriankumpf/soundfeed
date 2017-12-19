defmodule SoundfeedCore.Feed.Helper do
  use Timex

  @spec now_rfc1123() :: String.t()
  def now_rfc1123 do
    {:ok, date} = Timex.format(Timex.now(), "{RFC1123}")
    date
  end
end
