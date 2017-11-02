defmodule FitbitClient.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :caren_id, :integer
      add :fitbit_id, :string
      add :name, :string
      add :email, :string

      timestamps
    end
  end
end
