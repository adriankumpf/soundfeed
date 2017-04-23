defmodule Server.Web do
  def controller do
    quote do
      use Phoenix.Controller, namespace: Server.Web
      import Plug.Conn
      import Server.Web.Router.Helpers
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/server/web/templates",
                        namespace: Server.Web

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Server.Web.Router.Helpers
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
