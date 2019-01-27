defmodule CoreWeb.AuthController do
  use CoreWeb.Web, :controller
  plug Ueberauth

  alias Auth

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def request(conn, %{"provider" => "nopass"} = _params) do
    case conn.assigns[:status] do
      nil ->
        conn |> put_view(CoreWeb.AuthView) |> render("nopass.html")
      :ok_waiting ->
        conn |> put_view(CoreWeb.AuthView) |> render("nopass_waiting.html")
    end
  end

  def request(conn, %{"provider" => provider} = _params) do
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
  def callback(%{assigns: %{ueberauth_failure: fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.  #{inspect fails}")
    |> redirect(to: "/")
  end

  # Register user (pass), checks if ?reg=1, otherwise login
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn,
               %{"provider" => "identity", "reg" => "1"} = params) do
    case Auth.create(auth) do
      {:ok, user} ->
        conn
        |> CoreWeb.Guardian.Plug.sign_in(user)
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
        |> CoreWeb.Guardian.Plug.sign_in(user)
        |> put_flash(:info, "Logged in!")
        |> redirect_back(params)
      {:error, _} ->
        %{"email" => email} = params
        conn
        |> put_flash(:info, "Something wasn't right, try again!")
        |> redirect(to: "/auth/identity?email=" <> email <> "&" <> conn.query_string)
    end
  end

  # NOPASS Callback
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, %{"provider" => "nopass"} = params) do
    case Auth.find(auth) do
      {:ok, user} ->
        conn
        |> CoreWeb.Guardian.Plug.sign_in(user)
        |> put_flash(:info, "Logged in!")
        |> redirect_back(params)
      {:error, _} ->
        case Auth.create(auth) do
          {:ok, user} ->
            conn
            |> CoreWeb.Guardian.Plug.sign_in(user)
            |> put_flash(:info, "Logged in!")
            |> redirect_back(params)
          {:error, _} ->
            conn
            |> put_flash(:error, "Something went wrong")
            |> redirect(to: "/")
        end
    end
  end

  def signout(conn, _param) do
    conn
    |> CoreWeb.Guardian.Plug.sign_out()
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

  def loggedin(conn, _params) do
    if Guardian.Plug.current_resource(conn) do
      conn |> text("true")
    else
      conn |> text("false")
    end
  end
end
