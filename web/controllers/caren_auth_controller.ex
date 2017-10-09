defmodule FitbitClient.CarenAuthController do
  use FitbitClient.Web, :controller
  alias FitbitClient.User

  def index(conn, _params) do
    redirect conn, external: Caren.authorize_url!(scope: "user.read")
  end

  def callback(conn, %{"code" => code}) do
    token = Caren.get_token(code: code)
    user = OAuth2.Client.get!(token, "/api/v1/user").body
    default_user = user["_embedded"]["person"]
    changeset = User.changeset(%User{},
      %{
        name: default_user["first_name"],
        email: default_user["email"],
        access_token: token.token.access_token,
        refresh_token: token.token.refresh_token,
        caren_id: default_user["id"]
      })
      Repo.insert!(changeset)
      conn
        |> put_flash(:info, "Welcome #{default_user["first_name"]}.")
        |> redirect(to: "/")
  end
end
