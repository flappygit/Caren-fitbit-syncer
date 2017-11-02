defmodule FitbitClient.FitbitAuthController do
  use FitbitClient.Web, :controller
  alias FitbitClient.User

  def index(conn, _params) do
    redirect conn, external: Fitbit.authorize_url!(scope: "profile activity settings sleep heartrate")
  end

  def callback(conn, %{"code" => code}) do
    token = Fitbit.get_token!(code: code)
    user = OAuth2.Client.get!(token, "/1/user/-/profile.json").body
    name = user["user"]["fullName"]
    monthly_data = OAuth2.Client.get!(token, "/1/user/-/activities/steps/date/today/1m.json").body
    build_observations(user, monthly_data["activities-steps"], [])
      |> post_observations

    changeset = User.changeset(%User{},
      %{
        name: name,
        user_id: token.token.other_params["user_id"],
        access_token: token.token.access_token,
        refresh_token: token.token.refresh_token,
        fitbit_id: token.token.other_params["user_id"]
      })
      Repo.insert!(changeset)

      conn
      |> put_session(:current_user, "Fitbit ID: #{token.token.other_params["user_id"]}")
      |> redirect(to: "/")
  end

  def build_observations(user, [activity | tail], observations) do
    observation = %{
      "code" => "55423-8",
      "effectiveDateTime" => activity["dateTime"] <> " 00:00",
      "performer" => user["user"]["fullName"],
      "valueQuantity" => %{
        "value" => activity["value"]
      },
      "about_person" => 1,
      "external_updated_at" => activity["dateTime"] <> " 00:00"
    }
    build_observations(user, tail, [observation | observations])
  end

  def build_observations(user, [], observations) do
    observations
  end

  def post_observations([head | tail]) do
    encoded_value = Poison.encode!(head)
    url = "http://localhost:3005/api/v1/dossier_entries/measurements"
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJwZXJzb25faWQiOjEsImVsZXZhdGVkIjpmYWxzZSwidGltZV9pbl9taWxsaXNlY29uZHMiOjE1MDk2MTAxMzcyNTJ9.iClQy_G5FAbL4mAn_RNwZggYzRP9AdBtaehx0Y6snSUplg5jPw2QLv1RsWnQXzV1ykciuFI7a8lrOu654h0TJA"
    headers = ["Authorization": "Bearer #{token}", "Content-Type": "application/json", "Accept": "Application/json"]
    HTTPoison.post(url, encoded_value, headers)
    post_observations(tail)
  end

  def post_observations([]) do
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def fitbit_sync(conn, _params) do
    session = get_session(conn, :current_user)
     |> String.split(" ")
     |> Enum.at(2)

    user_token = User |> where([p], p.fitbit_id in [^session]) |> Repo.all
      |> Enum.at(0)

    request_fitbit_data(user_token)
    conn
    |> put_flash(:info, "Successfully synced.")
    |> redirect(to: "/")
  end

  def request_fitbit_data(user_token) do
    url = "https://api.fitbit.com/1/user/-/activities/steps/date/today/1d.json"
    headers = ["Authorization": "Bearer #{user_token.access_token}", "Accept": "Application/json"]

    {:ok, response} = HTTPoison.get(url, headers)
    synced_data = response.body
      |> Poison.decode!

    {:ok, fitbit_user} = HTTPoison.get("https://api.fitbit.com/1/user/-/profile.json", headers)
    observation_user = Poison.decode!(fitbit_user.body)

    build_observations(observation_user, synced_data["activities-steps"], [])
      |> post_observations
  end
end
