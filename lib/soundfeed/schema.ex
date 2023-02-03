defmodule SoundFeed.Schema do
  @moduledoc false

  @callback into(Enumerable.t()) :: struct

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)

      import unquote(__MODULE__), only: [key_to_existing_atom: 1]

      @impl true
      def into(attrs) do
        fields = Enum.map(attrs, &key_to_existing_atom/1)
        struct(__MODULE__, fields)
      end

      defoverridable into: 1
    end
  end

  def key_to_existing_atom({key, val}) do
    {String.to_existing_atom(key), val}
  rescue
    ArgumentError -> {key, val}
  end
end
