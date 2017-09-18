defmodule FitbitClient.PageController do
  use FitbitClient.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
