defmodule FitbitClient.FitbitAuthController do
  use FitbitClient.Web, :controller
  alias FitbitClient.User

  def index(conn, _params) do
    redirect conn, external: Fitbit.authorize_url!(scope: "profile activity heartrate")
  end

  def callback(conn, %{"code" => code}) do
    current_user = get_session(conn, :current_user)
    token = Fitbit.get_token!(code: code)

    monthly_steps_data = OAuth2.Client.get!(token, "/1/user/-/activities/steps/date/today/1m.json").body
    activities_heart_intraday = OAuth2.Client.get!(token, "/1/user/-/activities/heart/date/today/1d/1min/time/00:00/23:59.json").body

    build_observations_steps(current_user, monthly_steps_data["activities-steps"], [])
      |> post_observations_steps(conn)

    build_observations_heart(current_user, activities_heart_intraday["activities-heart-intraday"], [])
      |> post_observations_heart(conn)

    fetch_user_from_db = User |> FitbitClient.Repo.get_by(id: current_user.id)
      |> FitbitClient.Repo.preload(:tokens)
    changeset = User.changeset(fetch_user_from_db,
      %{
        fitbit_id: token.token.other_params["user_id"]
      })
      updated_user = Repo.update!(changeset)

    user_token_assoc = Ecto.build_assoc(updated_user, :tokens,
      %{
        provider: "fitbit",
        expires_in: token.token.expires_at,
        access_token: token.token.access_token,
        refresh_token: token.token.refresh_token
      })
      Repo.insert!(user_token_assoc)

    user_with_tokens = FitbitClient.Repo.get(FitbitClient.User, current_user.id)
      |> FitbitClient.Repo.preload(:tokens)

      conn
      |> put_flash(:info, "Succesfully linked your Fitbit account")
      |> put_session(:current_user, user_with_tokens)
      |> redirect(to: "/")
  end


  ################################## STEPS ##################################

  def build_observations_steps(user, [activity | tail], observations) do
    observation = %{
      "code" => "55423-8",
      "effectiveDateTime" => activity["dateTime"] <> " 00:00",
      "performer" => user.name,
      "valueQuantity" => %{
        "value" => activity["value"]
      },
      "about_person" => user.caren_id,
      "external_updated_at" => activity["dateTime"] <> " 00:00"
    }
    build_observations_steps(user, tail, [observation | observations])
  end

  def build_observations_steps(user, [], observations) do
    observations
  end

  def post_observations_steps(list, opts \\ [])

  def post_observations_steps([head | tail], conn) do
    session = get_session(conn, :current_user)
    temp_token = Enum.map(session.tokens, fn(token) -> token end)
      |> Enum.reject(fn t -> t.provider != "caren" end)
      |> Enum.at(0)

    encoded_value = Poison.encode!(head)
    url = "https://carenzorgt.nl/api/v1/dossier_entries/measurements"
    token = temp_token.access_token
    headers = ["Authorization": "Bearer #{token}", "Content-Type": "application/json", "Accept": "Application/json"]
    HTTPoison.post(url, encoded_value, headers)
    post_observations_steps(tail, conn)
  end

  def post_observations_steps([], conn) do
  end

  ################################## END ##################################


  ################################## HEART ##################################

  def build_observations_heart(user, [activity | tail], observations) do
    observation = %{
      "code" => "8867-4",
      "effectiveDateTime" => activity["dataset"]["time"],
      "performer" => user.name,
      "valueQuantity" => %{
        "value" => activity["dataset"]["value"]
      },
      "about_person" => user.caren_id,
      "external_updated_at" => activity["dataset"]["time"]
    }
    build_observations_heart(user, tail, [observation | observations])
  end

  def build_observations_heart(user, [], observations) do
    observations
  end

  def post_observations_heart(list, opts \\ [])

  def post_observations_heart([head | tail], conn) do
    session = get_session(conn, :current_user)
    temp_token = Enum.map(session.tokens, fn(token) -> token end)
      |> Enum.reject(fn t -> t.provider != "caren" end)
      |> Enum.at(0)

    encoded_value = Poison.encode!(head)
    url = "https://carenzorgt.nl/api/v1/dossier_entries/measurements"
    token = temp_token.access_token
    headers = ["Authorization": "Bearer #{token}", "Content-Type": "application/json", "Accept": "Application/json"]
    HTTPoison.post(url, encoded_value, headers)
    post_observations_heart(tail, conn)
  end

  def post_observations_heart([], conn) do
  end

  ################################## END ##################################

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def fitbit_sync(conn, _params) do
    session = get_session(conn, :current_user)

    temp_token = Enum.map(session.tokens, fn(token) -> token end)
      |> Enum.reject(fn t -> t.provider != "fitbit" end)
      |> Enum.at(0)

    url = "https://api.fitbit.com/1/user/-/activities/steps/date/today/1d.json"
    headers = ["Authorization": "Bearer #{temp_token.access_token}", "Accept": "Application/json"]

    {:ok, response} = HTTPoison.get(url, headers)
    synced_data = response.body
      |> Poison.decode!

    {:ok, fitbit_user} = HTTPoison.get("https://api.fitbit.com/1/user/-/profile.json", headers)
    observation_user = Poison.decode!(fitbit_user.body)

    required_syntax_temp = %{name: observation_user["user"]["fullName"]}
    build_observations_steps(required_syntax_temp, synced_data["activities-steps"], [])
      |> post_observations_steps(conn)

    conn
      |> put_flash(:info, "Successfully synced: #{Enum.at(synced_data["activities-steps"], 0)["value"]} steps")
      |> redirect(to: "/")
  end
end
