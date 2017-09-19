defmodule FitbitClient.AuthController do
  use FitbitClient.Web, :controller

  def index(conn, _params) do
    redirect conn, external: Fitbit.authorize_url!(scope: "settings sleep")
  end
end
