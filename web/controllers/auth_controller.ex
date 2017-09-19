defmodule FitbitClient.AuthController do
  use FitbitClient.Web, :controller
  alias FitbitClient.User

  def index(conn, _params) do
    redirect conn, external: Fitbit.authorize_url!(scope: "profile activity settings sleep")
  end

  def callback(conn, %{"code" => code}) do
    token = Fitbit.get_token!(code: code)
    user = OAuth2.Client.get!(token, "/1/user/-/profile.json").body
    name = user["user"]["fullName"]
    changeset = User.changeset(%User{},
      %{
        name: name,
        user_id: token.token.other_params["user_id"],
        access_token: token.token.access_token,
        refresh_token: token.token.refresh_token
      })
      Repo.insert!(changeset)

      conn
        |> put_flash(:info, "User #{name}.")
        |> redirect(to: "/")
  end
end
