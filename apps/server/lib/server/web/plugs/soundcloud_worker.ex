defmodule Server.Web.Plugs.SoundcloudWorker do
  import Plug.Conn

  def start_genserver(conn, _opts) do
    IO.puts "start_genserver plug"
    conn
  end
end
