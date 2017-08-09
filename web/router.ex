defmodule Core.Router do
  use Core.Web, :router
  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    # plug Guardian.Plug.LoadResource, don't really care usually
    plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__
  end

  scope "/", Core do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/", Core do
    pipe_through [:browser, :browser_auth]

    get "/profile", PageController, :index
  end

  scope "/auth", Core do
    pipe_through :browser

    get "/", AuthController, :index
    get "/exit", AuthController, :signout

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> put_flash(:info, "Please log in")
    |> redirect(to: "/auth/identity")
  end

  # Other scopes may use custom stacks.
  # scope "/api", Core do
  #   pipe_through :api
  # end
end
