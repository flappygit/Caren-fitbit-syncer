defmodule FitbitClient.CarenAuthController do
  use FitbitClient.Web, :controller
  alias FitbitClient.User
  alias FitbitClient.Token

  def index(conn, _params) do
    redirect conn, external: Caren.authorize_url!(scope: "user.read")
  end

  def callback(conn, %{"code" => code}) do
    token = Caren.get_token(code: code)
    user = OAuth2.Client.get!(token, "/api/v1/user").body
    default_user = user["_embedded"]["person"]
    user_changeset = User.changeset(%User{},
      %{
        name: default_user["first_name"],
        email: default_user["email"],
        caren_id: default_user["id"]
      })

    inserted_user = Repo.insert!(user_changeset)

    user_token_assoc = Ecto.build_assoc(inserted_user, :tokens,
      %{
        access_token: token.token.access_token,
        refresh_token: token.token.refresh_token,
        expires_in: token.token.expires_at
      })
      Repo.insert!(user_token_assoc)

    user_with_tokens = FitbitClient.Repo.get(FitbitClient.User, inserted_user.id)
      |> FitbitClient.Repo.preload(:tokens)

    conn
      |> put_flash(:info, "Welcome, #{default_user["first_name"]}")
      |> put_session(:current_user, user_with_tokens)
      |> redirect(to: "/")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
