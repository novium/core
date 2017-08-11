defmodule Core.AuthController do
  use Core.Web, :controller
  plug Ueberauth
  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.EnsureNotAuthenticated, handler: Core.AuthController

  alias Auth
  alias Ueberauth.Strategy.Helpers

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def request(conn, %{"provider" => provider} = params) do
    case provider do
      "identity" ->
        conn |> render("request.html")
      _ = provider -> conn
                      |> put_flash(:error, "Selected provider (#{provider}) doesn't exist")
                      |> redirect(to: "/")
    end
  end

  # Callbacks

  # Auth failed completely
  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  # Register user (pass), checks if ?reg=1, otherwise login
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn,
               %{"provider" => "identity", "reg" => "1"} = params) do
    case Auth.create(auth) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "registered") 
        |> redirect_back(params)
      {:error, reason} ->
        %{"email" => email} = params
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/auth/identity?email=" <> email)
    end
  end

  # Login user (pass)
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, %{"provider" => "identity"} = params) do
    case Auth.find(auth) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "Logged in!")
        |> redirect_back(params)
      {:error, reason} ->
        %{"email" => email} = params
        conn
        |> put_flash(:info, "Something wasn't right, try again!")
        |> redirect(to: "/auth/identity?email=" <> email <> "&" <> conn.query_string)
    end
  end

  def signout(conn, _param) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_flash(:info, "Signed out")
    |> redirect(to: "/")
  end

  def already_authenticated(conn, _params) do
    redirect(conn, to: "/")
  end

  defp redirect_back(conn, _params) do
    case get_session(conn, :auth_redirect) do
      nil -> conn |> redirect(to: "/")
      url ->
        conn
        |> put_session(:auth_redirect, nil)
        |> redirect(external: url)
    end
  end
end
