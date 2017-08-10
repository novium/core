defmodule Core.OAuth.Code do
  @moddoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.OAuth.Code

  schema "oauth_codes" do
    field :code, :string
    field :user_id, :binary_id
    field :client_id, :binary_id

    field :scope, :string

    timestamps()
  end

  def changeset(%Code{} = code, attrs) do
    code
    |> cast(attrs, [:code, :user_id, :client_id, :scope])
    |> unique_constraint(:code)
  end
end
