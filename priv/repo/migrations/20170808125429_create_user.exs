defmodule Core.Repo.Migrations.CreateUser do
  @moduledoc """
  Create user table
  """
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :uid, :"bigint unsigned", primary_key: true
      add :oid, :binary_id
      add :email, :string
      add :nick, :string

      add :password, :string

      add :is_admin, :boolean, default: false

      timestamps()
    end

    create index(:users, [:nick])
    create unique_index(:users, [:uid])
    create unique_index(:users, [:email])
    create unique_index(:users, [:oid])
  end
end
