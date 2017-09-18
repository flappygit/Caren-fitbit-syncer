defmodule FitbitClient.UserTest do
  use FitbitClient.ModelCase

  alias FitbitClient.User

  @valid_attrs %{access_token: "some access_token", email: "some email", name: "some name", refresh_token: "some refresh_token"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
