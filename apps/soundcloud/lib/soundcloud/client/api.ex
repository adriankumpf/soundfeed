defmodule Soundcloud.Client.API do
  alias HTTPoison.{Error, Response}

  alias Soundcloud.Models.{ErrorMessage, Errors}
  alias Soundcloud.Models.PagedResponse, as: Page
  alias Soundcloud.Models.Track

  defmacro __using__(_params) do
    quote do
      require Logger

      @behaviour Soundcloud.Client.API

      @client_id Application.get_env(:soundcloud, :client_id)

      def url(_user_id), do: ''
      def body, do: %Page{collection: [%Track{}]}
      def normalize(tracks), do: tracks

      defoverridable [url: 1, body: 0, normalize: 1]

      def fetch(user_id) do
        try do
          tracks = user_id |> url |> get([
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
        catch
          err -> {:error, err}
        end
      end

      defp get(url, params \\ []) do
        HTTPoison.get(url, [], params: params)
        |> parse_resp
        |> paginate
      end

      defp parse_resp({:ok, %Response{status_code: 200, body: data}}) do
        Poison.decode!(data, as: body())
      end
      defp parse_resp({:ok, %Response{status_code: 404, body: err}}) do
        Poison.decode!(err, as: %Errors{errors: [%ErrorMessage{}]})
        |> Map.get(:errors, [])
        |> hd
      end
      defp parse_resp({:ok, %Response{status_code: 401}}) do
        %ErrorMessage{error_message: "Forbidden"}
      end
      defp parse_resp({:ok, %Response{status_code: _, body: body}}) do
        %ErrorMessage{error_message: body}
      end
      defp parse_resp({:error, %Error{reason: reason}}) do
        %ErrorMessage{error_message: reason}
      end

      defp paginate(%Page{collection: col, next_href: nil}), do: col
      defp paginate(%Page{collection: col, next_href: url}), do: col ++ get(url)
      defp paginate(%ErrorMessage{} = error), do: error
      defp paginate(result), do: result
    end
  end
end
