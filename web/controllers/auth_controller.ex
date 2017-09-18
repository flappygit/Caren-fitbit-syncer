defmodule FitbitClient.AuthController do
  use FitbitClient.Web, :controller

  def index(conn, _params) do
    redirect conn, external: "https://www.fitbit.com/oauth2/authorize"
  end
end
