defmodule Core.User do
  @moduledoc """
  User model
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uid, :integer, autogenerate: false}
  @derive {Phoenix.Param, key: :uid}
  schema "users" do
    field :oid, :string # OpenID
    field :email, :string
    field :nick, :string

    field :password, :string

    field :is_admin, :boolean, default: false

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:uid, :email, :nick, :password, :is_admin])
    |> validate_required([:uid, :email, :is_admin])
    |> validate_length(:nick, max: 32)
    |> unique_constraint(:email)
    |> unique_constraint(:uid)
    |> unique_constraint(:oid)
  end
end
