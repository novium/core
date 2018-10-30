defmodule Core.OAuth.Authorization do
  @moddoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.OAuth.Authorization

  schema "oauth_authorizations" do
    field :token, :binary_id
    field :refresh_token, :binary_id
    field :scope, :string
    field :expires, :integer

    belongs_to :user, Core.User
    belongs_to :oauth_client, Core.OAuth.Client

    timestamps()
  end

  def changeset(%Authorization{} = auth, attrs) do
    auth
    |> cast(attrs, [:token, :refresh_token, :scope, :expires])
    |> validate_required([:token, :refresh_token, :scope, :expires])
    |> unique_constraint(:token)
  end
end
