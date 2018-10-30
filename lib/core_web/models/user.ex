defmodule Core.User do
  @moduledoc """
  User model
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :oid, :binary_id # Open "ID"
    field :email, :string
    field :nick, :string
    field :password, :string
    field :is_admin, :boolean, default: false

    has_many :oauth_authorizations, Core.OAuth.Authorization

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:oid, :email, :nick, :password, :is_admin])
    |> validate_required([:oid, :email, :is_admin])
    |> validate_length(:nick, max: 32)
    |> unique_constraint(:email)
    |> unique_constraint(:oid)
  end
end
