defmodule Ui.ApiController do
  require Logger
  use Ui, :controller

  alias Ui.Cache

  def show(conn, %{"user" => user}) do
    case Cache.get(Core, :lookup, [user]) do
      {:ok, user_id} ->
        json(conn, %{user_id: user_id})

      {:error, :not_found} ->
        send_resp(conn, 404, "")

      {:error, reason} ->
        _ = Logger.error("Failed to resolve the user \"#{user}\": #{reason}")
        send_resp(conn, 500, "")
    end
  end
end
