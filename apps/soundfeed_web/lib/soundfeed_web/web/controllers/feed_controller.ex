defmodule SoundfeedWeb.Web.FeedController do
  use SoundfeedWeb.Web, :controller

  # This will never be reached. It's just necessary
  # for the router to link to a controller.
  def dummy(conn, _params), do: send_resp(conn, 500, "")

end