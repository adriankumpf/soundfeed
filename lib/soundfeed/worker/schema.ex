defmodule SoundFeed.Schema do
  @moduledoc false

  @callback into(Enumerable.t()) :: struct

  defmacro __using__(_opts) do
    quote do
      @behaviour SoundFeed.Schema

      @impl true
      def into(attrs) do
        fields = Enum.map(attrs, &key_to_exising_atom/1)
        struct(__MODULE__, fields)
      end

      defoverridable into: 1

      defp key_to_exising_atom({key, val}) do
        {String.to_existing_atom(key), val}
      rescue
        ArgumentError -> {key, val}
      end
    end
  end
end
