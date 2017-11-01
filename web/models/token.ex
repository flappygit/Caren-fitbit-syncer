defmodule FitbitClient.Token do
  use FitbitClient.Web, :model

  schema "tokens" do
    belongs_to :user, FitbitClient.User
    field :access_token, :string
    field :refresh_token, :string
    field :expires_in, :string
    timestamps()
  end

  @required_fields ~w(access_token refresh_token expires_in)
  @optional_fields ~w()

  def changeset(model, params \\ %{}) do
    model
      |> cast(params, @required_fields, @optional_fields)
  end

end
