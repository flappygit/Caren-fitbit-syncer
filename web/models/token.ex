defmodule FitbitClient.Token do
  use FitbitClient.Web, :model

  schema "tokens" do
    belongs_to :user, FitbitClient.User
    field :provider, :string
    field :access_token, :string
    field :refresh_token, :string
    field :expires_in, :integer
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:access_token, :refresh_token, :expires_in, :provider])
  end

end
