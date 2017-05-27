defmodule Soundcloud.Client.API do
  alias HTTPoison.Response

  alias Soundcloud.Models.{ErrorMessage, Errors}
  alias Soundcloud.Models.PagedResponse, as: Page
  alias Soundcloud.Models.Track

  defmacro __using__(_params) do
    quote do
      @behaviour Soundcloud.Client.API

      @client_id Application.get_env(:soundcloud, :client_id)

      def url(_user_id), do: ''
      def body, do: %Page{collection: [%Track{}]}
      def normalize(tracks), do: tracks

      defoverridable [url: 1, body: 0, normalize: 1]

      def fetch(user_id) do
        tracks = get(url(user_id), [
          linked_partitioning: 1,
          client_id: @client_id,
          limit: 200
        ])

        case tracks do
          %ErrorMessage{error_message: msg} ->
            {:error, msg}
          _ ->
            {:ok, normalize(tracks)}
        end
      end

      defp get(url, params \\ []) do
        HTTPoison.get!(url, [], params: params)
        |> parse_json
        |> paginate
      end

      defp parse_json(%Response{status_code: 200, body: data}) do
        Poison.decode!(data, as: body())
      end
      defp parse_json(%Response{status_code: 404, body: err}) do
        Poison.decode!(err, as: %Errors{errors: [%ErrorMessage{}]})
        |> Map.get(:errors, [])
        |> hd
      end
      defp parse_json(%Response{status_code: 401}) do
        %ErrorMessage{error_message: "Forbidden"}
      end
      defp parse_json(%Response{status_code: _, body: body}) do
        %ErrorMessage{error_message: body}
      end

      defp paginate(%Page{collection: col, next_href: nil}), do: col
      defp paginate(%Page{collection: col, next_href: url}), do: col ++ get(url)
      defp paginate(%ErrorMessage{} = error), do: error
      defp paginate(obj), do: obj
    end
  end
end
