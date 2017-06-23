defmodule Soundcloud.Client.Resolver do
  require Logger

  alias HTTPoison.{Error, Response}

  @client_id Application.get_env(:soundcloud, :client_id)

  def lookup(user_id) do
    case HTTPoison.get("http://api.soundcloud.com/resolve", [], params: [
      url: "http://soundcloud.com/#{user_id}",
      client_id: @client_id
    ]) do
      {:ok, %Response{status_code: 302, headers: headers}} ->
        {:ok, extract_user_id(headers)}
      {:ok, %Response{status_code: 404}} ->
        {:error, :not_found}
      {:ok, %Response{status_code: _}} ->
        {:error, :bad_status_code}
      {:error, %Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp extract_user_id(headers) do
    headers
    |> get_location
    |> get_user_id
  end

  defp get_location([{"Location", loc} | _]), do: loc
  defp get_location([_ | headers]), do: get_location(headers)

  defp get_user_id("https://api.soundcloud.com/users/" <> user_id) do
    split_left(user_id, "?")
  end

  defp split_left(string, sep) do
    case :binary.match(string, [sep]) do
      {start, _length} ->
        <<left::binary-size(start), _::binary>> = string
        left
      :nomatch -> string
    end
  end
end
