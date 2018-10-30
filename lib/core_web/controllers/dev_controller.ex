defmodule CoreWeb.DevController do
  @moddoc false
  use CoreWeb.Web, :controller
  alias Core.OAuth.Client

  def index(conn, _params) do
    conn
    |> render("index.html", callback: "/dev/oauthclient")
  end

  def create_oauthclient(conn, %{"name" => name, "url" => url, "redirect" => redirect} = _params) do
    result = Client.changeset(
      %Client{},
      %{
        cid: Ecto.UUID.generate(),
        name: name,
        url: url,
        redirect: redirect,
        secret: Ecto.UUID.generate(),
        trusted: true
      }
    ) |> Repo.insert

    case result do
      {:ok, client} -> text(conn, "Client created: #{inspect client}")
      _ -> text(conn, "Something was wrong")
    end
  end
end
