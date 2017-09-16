defmodule SoundfeedCore.Client.API do
  alias HTTPoison.{Error, Response}
  alias SoundfeedCore.Models.PagedResponse, as: Page
  alias SoundfeedCore.Models.{User, Track}

  @typep body :: Page.t | User.t

  @callback url(User.id) :: String.t
  @callback body() :: body
  @callback normalize([any]) :: [any]

  @optional_callbacks body: 0, normalize: 1

  defmacro __using__(_params) do
    quote do
      @behaviour SoundfeedCore.Client.API

      @client_id Application.get_env(:soundfeed_core, :client_id)

      @typep body   :: body
      @typep resp   :: {:error, any} | {:ok, body}
      @typep tracks :: [Track.t]
      @typep params :: [any]

      def url(_user_id), do: ''
      def body, do: %Page{collection: [%Track{}]}
      def normalize(data), do: data

      defoverridable [url: 1, body: 0, normalize: 1]

      @spec fetch(User.id) :: {:error, any} | {:ok, tracks | User.t}
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

      @spec get(String.t, tracks, params) :: resp
      defp get(url, acc \\ [], params \\ []) do
        url
        |> HTTPoison.get([], params: params)
        |> parse
        |> paginate(acc)
      end

      @spec parse({:error, Error.t} | {:ok, Response.t}) :: resp
      defp parse({:ok, %Response{status_code: 200, body: data}}), do:
        Poison.decode(data, as: body())
      defp parse({:ok, %Response{status_code: 401}}), do:
        {:error, :forbidden}
      defp parse({:ok, %Response{status_code: _, body: err}}), do:
        {:error, err}
      defp parse({:error, %Error{reason: reason}}), do:
        {:error, reason}

      @spec paginate(resp, tracks) :: {:error, any} | {:ok, User.t | tracks}
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
