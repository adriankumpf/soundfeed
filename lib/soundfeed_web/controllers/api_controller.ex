defmodule SoundFeedWeb.ApiController do
  use SoundFeedWeb, :controller

  require Logger

  alias SoundFeedWeb.Cache

  def show(conn, %{"user" => user}) do
    case Cache.get(SoundFeed, :lookup, [user]) do
      {:ok, user_id} ->
        json(conn, %{user_id: user_id})

      {:error, :not_found} ->
        send_resp(conn, 404, "")

      {:error, reason} ->
        _ = Logger.error("Failed to resolve the user \"#{user}\": #{inspect(reason)}")
        send_resp(conn, 500, "")
    end
  end
end
