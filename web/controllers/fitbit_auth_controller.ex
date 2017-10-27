defmodule FitbitClient.FitbitAuthController do
  use FitbitClient.Web, :controller
  alias FitbitClient.User

  def index(conn, _params) do
    redirect conn, external: Fitbit.authorize_url!(scope: "profile activity settings sleep heartrate")
  end

  def callback(conn, %{"code" => code}) do
    token = Fitbit.get_token!(code: code)
    user = OAuth2.Client.get!(token, "/1/user/-/profile.json").body

    data_month_data = OAuth2.Client.get!(token, "/1/user/-/activities/steps/date/today/1m.json").body
    observation = Enum.map(data_month_data["activities-steps"], fn (activity) ->
      %{
        "coding" => [
          %{
            "code" => "55423-8",
            "codeSystem" => "http://loinc.org"
          }
        ],
        "effectiveDateTime" => activity["dateTime"] <> " 00:00",
        "valueQuantity" => %{
          "value" => activity["value"]
        }
      }end) |> encode_map_to_json

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

  def encode_map_to_json(observation) do
    encoded_observation = Poison.encode!(observation)
    IO.inspect(encoded_observation)
  end
end
