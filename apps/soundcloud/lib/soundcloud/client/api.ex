defmodule Soundcloud.Client.API do
  alias HTTPoison.Response

  alias Soundcloud.Models.PagedResponse, as: Page
  alias Soundcloud.Models.{ErrorMessage, Errors}

  defmacro __using__(_params) do
    quote do
      @behaviour Soundcloud.Client.API

      @client_id Application.get_env(:soundcloud, :client_id)

      def url(_userId), do: ''
      def collection, do: []
      def normalize(tracks), do: tracks

      defoverridable [url: 1, collection: 0, normalize: 1]

      def fetch(userId) do
        tracks = get(url(userId), [
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

      defp parse_json(%Response{status_code: 200, body: body}) do
        Poison.decode!(body, as: %Page{collection: collection()})
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
    end
  end
end
