defmodule Core.OAuth.Client do
  @moduledoc """
  OAuth2 Clients
  """
  #https://developers.google.com/oauthplayground/#step1&url=https%3A%2F%2F&content_type=application%2Fjson&http_method=GET&useDefaultOauthCred=unchecked&oauthEndpointSelect=Custom&oauthAuthEndpointValue=http%3A%2F%2Flocalhost%3A4000%2Foauth%2Fv1%2Fauthorize&oauthTokenEndpointValue=http%3A%2F%2Flocalhost%3A4000&oauthClientId=c39c96cc-686e-447f-8af2-2c6c4c0a9980&oauthClientSecret=074cfbd9-4ab0-49a4-9a7f-aa15a7a90c76&includeCredentials=checked&accessTokenType=bearer&autoRefreshToken=unchecked&accessType=offline&prompt=consent&response_type=code
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.OAuth.Client

  schema "oauth_clients" do
    field :cid, :binary_id
    field :name, :string
    field :url, :string
    field :image, :string

    field :redirect, :string
    field :secret, :binary_id

    field :trusted, :boolean

    timestamps()
  end

  @doc false
  def changeset(%Client{} = client, attrs) do
    client
    |> cast(attrs, [:cid, :name, :url, :image, :redirect, :secret, :trusted])
    |> validate_required([:cid, :name, :url, :redirect, :secret, :trusted])
    |> unique_constraint(:name)
    |> unique_constraint(:cid)
  end
end
