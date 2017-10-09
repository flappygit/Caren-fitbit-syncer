defmodule FitbitClient.Repo.Migrations.AddCarenIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :caren_id, :integer
    end
  end
end
