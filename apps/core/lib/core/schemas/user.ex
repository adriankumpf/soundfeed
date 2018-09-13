defmodule Core.Schemas.User do
  defstruct [:id, :username, :permalink_url, :avatar_url]

  @type id :: String.t()
  @type t :: %__MODULE__{
          id: id | nil,
          username: String.t() | nil,
          permalink_url: String.t() | nil,
          avatar_url: String.t() | nil
        }
end
