defmodule Core.Repo.Migrations.CreateOauthAuthorizations do
  use Ecto.Migration

  def change do
    create table :oauth_authorizations do
      add :token, :binary_id
      add :refresh_token, :binary_id
      add :scope, :string
      add :expires, :integer

      add :user_id, references(:users)
      add :oauth_client_id, references(:oauth_clients)

      timestamps()
    end

    create unique_index(:oauth_authorizations, :token)
    create index(:oauth_authorizations, :user_id)
    create index(:oauth_authorizations, :oauth_client_id)
  end
end
