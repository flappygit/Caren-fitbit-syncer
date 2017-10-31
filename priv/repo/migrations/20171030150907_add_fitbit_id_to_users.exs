defmodule FitbitClient.Repo.Migrations.AddFitbitIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :fitbit_id, :string
    end
  end
end
