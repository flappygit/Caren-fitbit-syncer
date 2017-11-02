defmodule FitbitClient.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :access_token, :string
      add :refresh_token, :string
      add :expires_in, :integer
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps
    end
    create index(:tokens, [:user_id])
  end
end
