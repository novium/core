defmodule Core.OauthController do
  @moduledoc """
  Oauth2 Controller
  """
  use Core.Web, :controller
  use Guardian.Phoenix.Controller
  alias Core.OAuth.Client
  alias Core.OAuth.Code
  alias Core.OAuth.Authorization
  alias Core.Repo

  def authorize(
    %{method: "GET"} = conn,
    %{"response_type" => "code", "client_id" => cid, "scope" => scope} = params, user, claims
  ) do    
    case Repo.get_by(Client, cid: cid) do
      nil ->
        conn
        |> put_status(400)
        |> text("Malformed request")
      client ->
        conn
        |> render("authorize.html", client: client, scope: scope)
    end
  end

  def authorize(
    %{method: "POST"} = conn,
    %{"client_id" => client_id, "scope" => scope}, {:ok, user}, claims
  ) do
    with client <- Repo.get_by(Core.OAuth.Client, cid: client_id),
      false <- is_nil(client),
      {:ok, code} <-
        Code.changeset(
          %Code{},
          %{
            code: Ecto.UUID.generate,
            user_id: user.oid,
            client_id: client_id,
            scope: scope
          }
        ) |> Repo.insert
    do
      redirect(conn, external: client.redirect <> "?code=" <> code.code)
    else
      {:error, reason} -> conn |> put_status(400) |> text("Something went wrong")
      _ -> conn |> put_status(400) |> text("Something went wrong")
    end
  end

  def authorize(conn, _params, _user, _claims) do
    conn
    |> put_status(400)
    |> text("Malformed request")
  end

  def token(conn,
  %{"grant_type" => "authorization_code",
  "code" => code,
  "redirect_uri" => redirect,
  "client_id" => client_id,
  "client_secret" => client_secret
  }, _user, _claims
  ) do
    with client <- Repo.get_by(Core.OAuth.Client, cid: client_id),
      code <- Repo.get_by(Code, code: code),
      false <- is_nil(client) || is_nil(code),
      user_db <- Repo.get_by(Core.User, oid: code.user_id),
      false <- is_nil(user_db),
      true <-
        client.cid == client_id
        && client.secret == client_secret
        && client.redirect == redirect
        && code.client_id == client_id,
      time <-
        NaiveDateTime.utc_now 
        |> NaiveDateTime.add(60 * 60 * 24 * 30) 
        |> NaiveDateTime.diff(NaiveDateTime.utc_now),
      {:ok, auth} <-
        %Authorization{user_id: user_db.id, oauth_client_id: client.id}
        |> Authorization.changeset(
          %{
            token: Ecto.UUID.generate,
            refresh_token: Ecto.UUID.generate,
            scope: code.scope,
            expires: time
          }
        )
        |> Repo.insert
    do
      json(conn, %{access_token: auth.token, refresh_token: auth.refresh_token, expires: auth.expires, email: user_db.email})
    else
      {:error, reason} ->
        json(conn, %{error: "invalid_request", reason: "reason"})
      _ -> json(conn, %{error: "invalid_request"})
    end
  end
end
