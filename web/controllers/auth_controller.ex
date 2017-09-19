defmodule FitbitClient.AuthController do
  use FitbitClient.Web, :controller
  alias FitbitClient.User

  def index(conn, _params) do
    redirect conn, external: Fitbit.authorize_url!(scope: "activity settings sleep")
  end

  def callback(conn, %{"code" => code}) do
    token = Fitbit.get_token!(code: code)
    IO.inspect(token)
    changeset = User.changeset(%User{},
      %{user_id: token.token.other_params["user_id"],
        access_token: token.token.access_token,
        refresh_token: token.token.refresh_token
      })
      Repo.insert!(changeset)

      conn
        |> put_flash(:info, "User created.")
        |> redirect(to: "/")
  end
end
