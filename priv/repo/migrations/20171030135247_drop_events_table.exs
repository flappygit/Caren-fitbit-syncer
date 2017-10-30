defmodule FitbitClient.Repo.Migrations.DropEventsTable do
  use Ecto.Migration

  def change do
    drop_if_exists table("events")
  end
end
