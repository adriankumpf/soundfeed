defmodule Server.Web.ApiController do
  use Server.Web, :controller

  alias Server.Web.Cache

  def show(conn, %{"user" => user}) do
    case Cache.get(Soundcloud, :lookup, [user]) do
      {:ok, user_id} ->
        json conn, %{user_id: user_id}
      {:error, :not_found} ->
        send_resp conn, 404, ""
      {:error, err} ->
        send_resp conn, 500, err
    end
  end
end
