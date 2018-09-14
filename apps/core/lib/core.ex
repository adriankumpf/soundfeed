defmodule Core do
  defdelegate new(type, user_id), to: Core.Controller
  defdelegate lookup(user), to: Core.Resolver
end
