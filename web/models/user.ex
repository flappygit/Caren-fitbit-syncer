defmodule FitbitClient.User do
  use FitbitClient.Web, :model

  schema "users" do
    has_many :tokens, FitbitClient.Token
    field :caren_id, :integer
    field :fitbit_id, :string
    field :name, :string
    field :email, :string
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :caren_id, :fitbit_id])
  end
end
