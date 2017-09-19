defmodule FitbitClient.AuthController do
  use FitbitClient.Web, :controller

  def index(conn, _params) do
    redirect conn, external: Fitbit.authorize_url!(scope: "activity settings sleep")
  end

  def callback(conn, %{"code" => code}) do
    token = Fitbit.get_token!(code: code)
    redirect conn, to: "/"
  end
end
