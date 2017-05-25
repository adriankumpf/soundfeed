defmodule Soundcloud.Client.Resolver do
  alias HTTPoison.Response

  @client_id Application.get_env(:soundcloud, :client_id)

  def lookup(user_id) do
    HTTPoison.get!("http://api.soundcloud.com/resolve", [], params: [
      url: "http://soundcloud.com/#{user_id}",
      client_id: @client_id
    ]) |> extract_user_id
  end

  defp extract_user_id(%Response{status_code: 404}), do: {:error, :not_found}
  defp extract_user_id(%Response{status_code: 302, headers: headers}) do
    user_id = headers
              |> get_location
              |> get_user_id
    {:ok, user_id}
  end

  defp get_location([{"Location", loc} | _]), do: loc
  defp get_location([_ | headers]), do: get_location(headers)

  defp get_user_id("https://api.soundcloud.com/users/" <> user_id) do
    user_id
    |> String.split("?")
    |> hd
  end
end
