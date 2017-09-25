defmodule FitbitClient.CarenAuthController do
  use FitbitClient.Web, :controller
  alias FitbitClient.User

  def index(conn, _params) do
    redirect conn, external: Caren.authorize_url!(scope: "user.read")
  end

  def callback(conn, %{"code" => code}) do
    token = Caren.get_token!(code: code)
    IO.inspect(token)
    conn
      |> put_flash(:info, "Succesfully signed in")
      |> redirect(to: "/")
  end
end
