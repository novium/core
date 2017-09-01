defmodule Core.OpenidController do
  use Core.Web, :controller

  @base_url "http://localhost:4001"

  def index(conn, _params) do
    conn
    |> json(%{
      issuer: @base_url,
      authorization_endpoint: @base_url <> "/oauth/v1/authorize",
      token_endpoint: @base_url <> "/token",
      userinfo_endpoint: "NONE",
      revocation_endpoint: "NONE",
      jwks_uri: "NONE", #TODO
      response_types_supported: [
        "code",
        "code id_token"
      ],
      scopes_supported: [
        "email",
        "openid"
      ],
      claims_supported: [
        "aud",
        "email",
        "email_verified",
        "exp",
        "iat",
        "iss",
        "sub"
       ]
    })
  end
end