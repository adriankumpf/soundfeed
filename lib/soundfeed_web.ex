defmodule SoundFeedWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: SoundFeedWeb

      import Plug.Conn
      import SoundFeedWeb.Gettext
      alias SoundFeedWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/soundfeed_web/templates",
        namespace: SoundFeedWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import SoundFeedWeb.ErrorHelpers
      import SoundFeedWeb.Gettext
      alias SoundFeedWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import SoundFeedWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
