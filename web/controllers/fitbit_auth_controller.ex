defmodule FitbitClient.FitbitAuthController do
  use FitbitClient.Web, :controller
  alias FitbitClient.User

  def index(conn, _params) do
    redirect conn, external: Fitbit.authorize_url!(scope: "profile activity settings sleep heartrate")
  end

  def callback(conn, %{"code" => code}) do
    token = Fitbit.get_token!(code: code)
    user = OAuth2.Client.get!(token, "/1/user/-/profile.json").body
    
    activities_steps = OAuth2.Client.get!(token, "/1/user/-/activities/steps/date/2017-10-26/1d.json").body
    temp = activities_steps["activities-steps"]
    get_steps_from_activities = Enum.map(temp, fn (x) -> x["value"] end)
    get_steps_from_array = Enum.at(get_steps_from_activities, 0)
    steps = String.to_integer(get_steps_from_array)

    name = user["user"]["fullName"]
    changeset = User.changeset(%User{},
      %{
        name: name,
        user_id: token.token.other_params["user_id"],
        access_token: token.token.access_token,
        refresh_token: token.token.refresh_token,
        steps: steps
      })
      Repo.insert!(changeset)

      conn
        |> put_flash(:info, "User #{name}.")
        |> redirect(to: "/")
  end
end
