defmodule CoreWeb.PageController do
  use CoreWeb.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
