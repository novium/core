defmodule Core.OauthController do
  @moduledoc """
  Oauth2 Controller
  """
  use Core.Web, :controller
  use Guardian.Phoenix.Controller
  alias Core.OAuth.Client
  alias Core.Repo

  def authorize(conn, %{"response_type" => "code", "client_id" => cid} = _params, user, claims) do
    case Repo.get_by(Client, cid: cid) do
      nil ->
        conn
        |> put_status(400)
        |> text("Malformed request")
      client ->
        conn
        |> render("authorize.html", client: client)
    end
  end

  def authorize(conn, _params, _user, _claims) do
    conn
    |> put_status(400)
    |> text("Malformed request")
  end
end
