defmodule Ui.PageLive do
  use Phoenix.LiveView

  require Logger

  alias Ui.Cache

  @impl true
  def mount(session, socket) do
    assigns = %{
      host: session.host,
      profile_url: "",
      type: "likes",
      feed_url: nil,
      error: false
    }

    {:ok, assign(socket, assigns)}
  end

  @impl true
  def render(assigns) do
    Ui.PageView.render("index.html", assigns)
  end

  @impl true
  def handle_event("generate", %{"profile_url" => profile_url, "type" => type}, socket) do
    socket = assign(socket, profile_url: profile_url, type: type)

    with {:ok, user} <- extract_user(profile_url),
         {:ok, user_id} <- get_user_id(user) do
      {:noreply, assign(socket, feed_url: "#{socket.assigns.host}/feeds/#{user_id}/#{type}.rss")}
    else
      {:error, _reason} -> {:noreply, shake_form(socket)}
    end
  end

  def handle_event("close", params, socket) when params == "Escape" or params == "" do
    {:noreply, assign(socket, feed_url: nil)}
  end

  def handle_event("close", _params, socket) do
    {:noreply, socket}
  end

  # @impl true
  def handle_info(:clear_error, socket) do
    {:noreply, assign(socket, error: false)}
  end

  # Private

  defp extract_user(profile_url) do
    with "soundcloud.com/" <> user_id <- profile_url |> String.trim() |> String.downcase(),
         false <- String.contains?(user_id, ["?", "/", "&", "#"]) do
      {:ok, user_id}
    else
      _ -> {:error, :invalid}
    end
  end

  defp get_user_id(user) do
    with {:error, reason} <- Cache.get(Core, :lookup, [user]) do
      Logger.warn("Failed to resolve the user \"#{user}\": #{reason}")
      {:error, reason}
    end
  end

  defp shake_form(socket) do
    Process.send_after(self(), :clear_error, 250)
    assign(socket, error: true)
  end
end
