defmodule Soundcloud.Client.API do
  alias HTTPoison.{Error, Response}

  alias Soundcloud.Models.Errors
  alias Soundcloud.Models.PagedResponse, as: Page
  alias Soundcloud.Models.{User, Track}

  defmacro __using__(_params) do
    quote do
      require Logger

      @behaviour Soundcloud.Client.API

      @client_id Application.get_env(:soundcloud, :client_id)

      def url(_user_id), do: ''
      def body, do: %Page{collection: [%Track{}]}
      def normalize(data), do: data

      defoverridable [url: 1, body: 0, normalize: 1]

      def fetch(user_id) do
        res = user_id |> url |> get([], [
          linked_partitioning: 1,
          client_id: @client_id,
          limit: 200
        ])

        case res do
          {:ok, data} -> {:ok, normalize(data)}
          {:error, reason} -> {:error, reason}
        end
      end

      defp get(url, acc \\ [], params \\ []) do
        HTTPoison.get(url, [], params: params)
        |> parse
        |> paginate(acc)
      end

      defp parse({:ok, %Response{status_code: 200, body: data}}), do:
        {:ok, Poison.decode!(data, as: body())}
      defp parse({:ok, %Response{status_code: 401}}), do:
        {:error, :forbidden}
      defp parse({:ok, %Response{status_code: _, body: err}}), do:
        {:error, err}
      defp parse({:error, %Error{reason: reason}}), do:
        {:error, reason}

      defp paginate({:error, reason}, _acc), do:
        {:error, reason}
      defp paginate({:ok, %User{} = user}, _acc), do:
        {:ok, user}
      defp paginate({:ok, %Page{collection: col, next_href: nil}}, acc), do:
        {:ok, acc ++ col}
      defp paginate({:ok, %Page{collection: col, next_href: url}}, acc), do:
        get(url, acc ++ col)
    end
  end
end
