defmodule FitbitClient.Repo.Migrations.CreateEvent do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :url, :string
      add :summary, :string
      add :description, :string
      add :location, :string
      add :caren_id, :integer
      add :dtstart, :string
      add :dtend, :string

      timestamps()
    end
  end
end
