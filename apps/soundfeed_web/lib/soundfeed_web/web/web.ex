defmodule SoundfeedWeb.Web do
  def controller do
    quote do
      use Phoenix.Controller, namespace: SoundfeedWeb.Web
      import Plug.Conn
      import SoundfeedWeb.Web.Router.Helpers
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/soundfeed_web/web/templates",
                        namespace: SoundfeedWeb.Web

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0,
                                        get_flash: 2,
                                        view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import SoundfeedWeb.Web.Router.Helpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
