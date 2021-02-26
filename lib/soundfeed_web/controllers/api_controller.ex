defmodule SoundFeedWeb.ApiController do
  use SoundFeedWeb, :controller

  require Logger

  def show(conn, %{"user" => user}) do
    case SoundFeed.Api.lookup_user(user) do
      {:ok, user_id} ->
        json(conn, %{user_id: user_id})

      {:error, :not_found} ->
        send_resp(conn, 404, "")

      {:error, reason} ->
        Logger.error("Failed to resolve the user \"#{user}\": #{inspect(reason)}")
        send_resp(conn, 500, "")
    end
  end
end
