defmodule FitbitClient.Router do
  use FitbitClient.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :assign_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FitbitClient do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
    resources "/users", UserController
    get "/sync", FitbitAuthController, :fitbit_sync
  end

  scope "/auth/fitbit", FitbitClient do
    pipe_through :browser
    get "/", FitbitAuthController, :index
    get "/callback", FitbitAuthController, :callback
    delete "/logout", FitbitAuthController, :delete
  end

  scope "/auth/caren", FitbitClient do
    pipe_through :browser
    get "/", CarenAuthController, :index
    get "/callback", CarenAuthController, :callback
    delete "/logout", CarenAuthController, :delete
  end

  defp assign_current_user(conn, _) do
    assign(conn, :current_user, get_session(conn, :current_user))
  end
end
