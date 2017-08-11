defmodule Core.Repo.Migrations.CreateOauthCodes do
  use Ecto.Migration

  def change do
    create table :oauth_codes do
      add :code, :binary_id
      add :user_id, :binary_id
      add :client_id, :binary_id

      add :scope, :string

      timestamps()
    end

    create unique_index(:oauth_codes, [:code])
  end
end
