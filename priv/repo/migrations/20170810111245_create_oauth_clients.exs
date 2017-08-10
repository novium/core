defmodule Core.Repo.Migrations.CreateOauthClients do
  use Ecto.Migration

  def change do
    create table :oauth_clients do
      add :cid, :binary_id
      add :name, :string
      add :url, :string
      add :image, :string

      add :redirect, :string
      add :secret, :binary_id

      add :trusted, :boolean

      timestamps()
    end

    create unique_index(:oauth_clients, [:cid])
    create unique_index(:oauth_clients, [:name])
  end
end
