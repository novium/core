defmodule CoreWeb.Router do
  use CoreWeb.Web, :router

  require Ueberauth
  require UeberauthNopass

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :authorized do
    plug CoreWeb.Guardian.BrowserAuthPipeline
  end

  pipeline :browser_auth do
    plug CoreWeb.Guardian.BrowserAuthPipeline
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    UeberauthNopass.mount_html
  end

  scope "/", CoreWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/", CoreWeb do
    pipe_through [:browser, :browser_auth]

    get "/profile", PageController, :index
  end

  scope "/auth", CoreWeb do
    pipe_through :browser

    get "/", AuthController, :index
    get "/exit", AuthController, :signout

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end

  # OAuth
  scope "/oauth", CoreWeb do
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

  scope "/dev", CoreWeb do
    pipe_through :browser

    get "/", DevController, :index
    post "/oauthclient", DevController, :create_oauthclient
  end

  scope "/api", CoreWeb do
    pipe_through :api

    scope "/oauth", API do
      get "/list", OAuthController, :list
      get "/create", OAuthController, :create
    end
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
