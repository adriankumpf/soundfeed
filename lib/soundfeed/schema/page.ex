defmodule SoundFeed.Schema.Page do
  use SoundFeed.Schema

  defstruct [:collection, :next_href]

  @type t :: %__MODULE__{collection: [any], next_href: String.t() | nil}
end
