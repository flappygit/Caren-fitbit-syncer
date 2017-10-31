defmodule FitbitClient.Repo.Migrations.AddStepsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :steps, :integer
    end
  end
end
