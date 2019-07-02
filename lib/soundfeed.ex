defmodule SoundFeed do
  defdelegate new(type, user_id), to: SoundFeed.Controller
  defdelegate lookup(user), to: SoundFeed.Resolver
end
