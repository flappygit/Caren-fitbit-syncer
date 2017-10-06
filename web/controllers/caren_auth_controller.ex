defmodule FitbitClient.CarenAuthController do
  use FitbitClient.Web, :controller
  alias FitbitClient.User

  def index(conn, _params) do
    redirect conn, external: Caren.authorize_url!(scope: "user.read")
  end

  def callback(conn, %{"code" => code}) do
    token = Caren.get_token(code: code)
    user = OAuth2.Client.get!(token, "/api/v1/user").body
    IO.inspect(token)
    first_name = user["_embedded"]["person"]["first_name"]
    email = user["_embedded"]["person"]["email"]
    changeset = User.changeset(%User{},
      %{
        name: first_name,
        email: email,
        access_token: token.token.access_token,
        refresh_token: token.token.refresh_token
      })
      Repo.insert!(changeset)
      conn
        |> put_flash(:info, "Welcome #{first_name}.")
        |> redirect(to: "/")
  end
end
