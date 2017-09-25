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
    plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureResource
  end

  pipeline :api do
    plug :accepts, ["json"]
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

  # OAuth
  scope "/oauth", Core do
    # Frontend
    scope "/v1" do
      pipe_through [:browser, :browser_auth]
      get "/authorize", OauthController, :authorize
      post "/authorize", OauthController, :authorize
    end

    # Backend
    scope "/v1" do
      pipe_through :api
      post "/token", OauthController, :token
      get "/userinfo", OauthController, :userinfo
    end
  end

  get "/.well-known/openid-configuration", Core.OpenidController, :index

  scope "/dev", Core do
    pipe_through :browser

    get "/", DevController, :index
    post "/oauthclient", DevController, :create_oauthclient
  end

  def unauthenticated(conn, params) do
    conn
    |> put_session(:auth_redirect, 
      "http://" <> conn.host 
      <> ":" <> Integer.to_string(conn.port)
      <> conn.request_path <> "?" <> conn.query_string)
    |> put_flash(:info, "Please log in")
    |> Phoenix.Controller.redirect(to: "/auth/identity")
  end

  # Other scopes may use custom stacks.
  # scope "/api", Core do
  #   pipe_through :api
  # end
end
