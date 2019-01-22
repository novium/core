defmodule CoreWeb.OauthController do
  @moduledoc """
  Oauth2 Controller
  """
  use CoreWeb.Web, :controller
  alias Core.OAuth.Client
  alias Core.OAuth.Code
  alias Core.OAuth.Authorization
  alias Core.Repo

  @issuer "localhost:4001"

  @doc """
  Adds default scope if missing
  """
  def authorize(
    %{method: "GET"} = conn,
    %{"response_type" => "code", "client_id" => cid, "scope" => ""} = params
  ) do
    authorize(conn, %{"response_type" => "code", "client_id" => cid, "scope" => "default"})
  end

  @doc """
  Begin authorization flow
  """
  def authorize(
    %{method: "GET"} = conn,
    %{"response_type" => "code", "client_id" => cid, "scope" => scope} = params
  ) do
    user = Guardian.Plug.current_resource(conn)

    case Repo.get_by(Core.OAuth.Authorization, user_id: user.id) do # TODO: Check scopes!
      nil ->
        case Repo.get_by(Client, cid: cid) do
          nil ->
            conn
            |> put_status(400)
            |> text("Malformed request")
          client ->
            conn
            |> render("authorize.html", client: client, scope: scope)
        end
       _ -> authorize_f(conn, cid, scope, user)
    end
  end

  @doc """
  Authorization accepted by user, redirect.
  """
  def authorize(
    %{method: "POST"} = conn,
    %{"client_id" => client_id, "scope" => scope}
  ) do
    
    user = Guardian.Plug.current_resource(conn)
    authorize_f(conn, client_id, scope, user)
  end

  defp authorize_f(conn, client_id, scope, user) do
    with client <- Repo.get_by(Core.OAuth.Client, cid: client_id),    # Get client
      false <- is_nil(client),                                        # Check that client exists
      {:ok, code} <- create_code(user, client.id, scope)              # Create code
    do
      redirect(conn, external: client.redirect <> "?code=" <> code.code)
    else
      {:error, reason} -> conn |> put_status(400) |> text("Something went wrong")
      _ -> conn |> put_status(400) |> text("Something went wrong")
    end
  end

  defp create_code(user, client_id, scope) do
    Code.changeset(
      %Code{user_id: user.id, oauth_client_id: client_id},
      %{
        code: Ecto.UUID.generate,
        scope: scope
      }
    ) |> Repo.insert
  end

  # Encode, decode and check if scopes exist!
  defp decode_scopes(scopes), do: String.split(scopes)
  defp encode_scopes(scopes) when is_bitstring(scopes), do: scopes
  defp encode_scopes(scopes), do: Enum.join(scopes, " ")
  defp find_scope(scopes, scope) when is_bitstring(scopes), do: scopes == scope
  defp find_scope(scopes, scope), do: not (Enum.find_value(scopes, fn a -> a == scope end) |> is_nil)

  # Bad request
  def authorize(conn, _params) do
    conn
    |> put_status(400)
    |> text("Malformed request")
  end

  @doc """
  Token exchange
  """
  def token(conn,
  %{"grant_type" => "authorization_code",
  "code" => code,
  "redirect_uri" => redirect,
  "client_id" => client_id,
  "client_secret" => client_secret
  }
  ) do
    with client <- Repo.get_by(Core.OAuth.Client, cid: client_id),
      code <- Repo.get_by(Code, code: code),
      false <- is_nil(client) || is_nil(code),
      user_db <- Repo.get(Core.User, code.user_id),
      false <- is_nil(user_db),
      true <-
        client.cid == client_id
        && client.secret == client_secret
        && client.redirect == redirect
        && code.oauth_client_id == client.id,
      scope <- decode_scopes(code.scope),
      auth <- Repo.get_by(Core.OAuth.Authorization, user_id: code.user_id)
    do
      if is_nil(auth) do
        changeset = %Authorization{user_id: user_db.id, oauth_client_id: client.id}
        |> Authorization.changeset(
          %{
            token: Ecto.UUID.generate,
            refresh_token: Ecto.UUID.generate,
            scope: code.scope,
            expires: expires(60 * 60 * 24 * 30)
          }
        )

        case Repo.insert(changeset) do
          {:ok, auth} ->
            if find_scope(scope, "openid") do
              openid_end(conn, user_db, code, auth)
            else
              oauth_end(conn, user_db, auth)
            end
          {:error, reason} -> Repo.rollback(reason)
        end
      else # TODO: Renew authorization
        if find_scope(scope, "openid") do
          openid_end(conn, user_db, code, auth)
        else
          oauth_end(conn, user_db, auth)
        end
      end
    else
      _ -> json(conn, %{error: "invalid_request", reason: "none"})
    end
  end

  @doc """
  Unauthenticated token exchange
  TODO: MERGE
  """
  def token(conn,
  %{
  "code" => code,
  "redirectUri" => redirect,
  "clientId" => client_id,
  }
  ) do
    with client <- Repo.get_by(Core.OAuth.Client, cid: client_id),
      code <- Repo.get_by(Code, code: code),
      false <- is_nil(client) || is_nil(code),
      user_db <- Repo.get(Core.User, code.user_id),
      false <- is_nil(user_db),
      true <-
        client.cid == client_id
        && client.redirect == redirect
        && code.oauth_client_id == client.id,
      scope <- decode_scopes(code.scope),
      auth <- Repo.get_by(Core.OAuth.Authorization, user_id: code.user_id)
    do
      if is_nil(auth) do
        changeset = %Authorization{user_id: user_db.id, oauth_client_id: client.id}
        |> Authorization.changeset(
          %{
            token: Ecto.UUID.generate,
            refresh_token: Ecto.UUID.generate,
            scope: code.scope,
            expires: expires(60 * 60 * 24 * 30)
          }
        )

        case Repo.insert(changeset) do
          {:ok, auth} ->
            if find_scope(scope, "openid") do
              openid_end(conn, user_db, code, auth)
            else
              oauth_end(conn, user_db, auth)
            end
          {:error, reason} -> Repo.rollback(reason)
        end
      else # TODO: Renew authorization
        if find_scope(scope, "openid") do
          openid_end(conn, user_db, code, auth)
        else
          oauth_end(conn, user_db, auth)
        end
      end
    else
      _ -> json(conn, %{error: "invalid_request", reason: "none"})
    end
  end

  defp create_jwt() do
    # Stub
  end

  defp openid_end(conn, user, code, auth) do
    json(conn, %{
      access_token: auth.token, refresh_token: auth.refresh_token, expires: auth.expires, email: user.email,
      id_token: %{
        iss: @issuer,
        sub: user.oid,
        email: user.email,
        email_verified: true, # TODO: Email verification
        aud: code.client_id,
        iat: NaiveDateTime.utc_now,
        exp: NaiveDateTime.utc_now |> NaiveDateTime.add(60 * 60 * 24),
        nonce: "" # TODO: nonce for flow replay attacks
      }
    })
  end

  defp oauth_end(conn, user, auth) do
    json(conn, %{access_token: auth.token, refresh_token: auth.refresh_token, expires: auth.expires})
  end

  defp expires(seconds) do
    NaiveDateTime.utc_now
    |> NaiveDateTime.add(seconds)
    |> NaiveDateTime.diff(NaiveDateTime.utc_now)
  end

  """
  def userinfo(conn, params) do
    if Enum.count(get_req_header(conn, "authorization")) > 0 do
      case token_from_header(get_req_header(conn, "authorization")) do
        {:ok, token} -> conn |> userinfo(token)
        {:error, reason} -> conn |> json(%{error: reason})
      end
    else
      case token_from_query(params) do
        {:ok, token} -> conn |> userinfo(token)
        {:error, reason} -> conn |> json(%{error: reason})
      end
    end
  end

  defp userinfo(conn, token) do
    with authorization <- Repo.get_by(Core.OAuth.Authorization, token: token),
      #true <- check_authorization(authorization),
      scopes <- decode_scopes(authorization.scope),
      true <- find_scope(scopes, "profile"),
      user <- Repo.get(Core.User, authorization.user_id),
      false <- is_nil(user)
    do
      conn
      |> json(%{
        coreid: user.oid,
        email: user.email
      })
    else
      _ -> conn |> json(%{error: "Something went wrong."})
    end

  end
  """

  defp token_from_header([header]) do
    header = String.split(header)
    case List.first(header) do
      a when a in ["OAuth", "Bearer"] -> {:ok, List.last(header)}
      _ -> {:error, "Invalid header"}
    end
  end

  defp token_from_query(%{"access_token" => token}), do: {:ok, token}
  defp token_from_query(_), do: {:error, "Invalid request"}

  defp check_authorization(nil), do: false
  defp check_authorization(%Core.OAuth.Authorization{} = authorization) do
    if NaiveDateTime.compare(NaiveDateTime.add(authorization.inserted_at, authorization.expires), NaiveDateTime.utc_now) == :lt do
      true
    else
      false
    end
  end
  defp check_authorization(_), do: false
end
