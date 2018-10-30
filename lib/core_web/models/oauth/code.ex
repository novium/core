defmodule Core.OAuth.Code do
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.OAuth.Code

  schema "oauth_codes" do
    field :code, :binary_id

    belongs_to :user, Core.User
    belongs_to :oauth_client, Core.OAuth.Client

    field :scope, :string

    timestamps()
  end

  def changeset(%Code{} = code, attrs) do
    code
    |> cast(attrs, [:code, :scope])
    |> unique_constraint(:code)
  end
end
