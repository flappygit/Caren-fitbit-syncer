defmodule FitbitClient.Repo.Migrations.AddProviderToTokens do
  use Ecto.Migration

  def change do
    alter table(:tokens) do
      add :provider, :string
    end
  end
end
