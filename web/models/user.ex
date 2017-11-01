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

  @required_fields ~w(name email)
  @optional_fields ~w(caren_id fitbit_id)

  def changeset(model, params \\ %{}) do
    model
      |> cast(params, @required_fields, @optional_fields)
  end
end
