defmodule FitbitClient.Router do
  use FitbitClient.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FitbitClient do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
    resources "/users", UserController
  end

  scope "/api", FitbitClient do
    pipe_through :api
    resources "/events", EventController
  end

  scope "/auth/fitbit", FitbitClient do
    pipe_through :browser
    get "/", FitbitAuthController, :index
    get "/callback", FitbitAuthController, :callback
  end

  scope "/auth/caren", FitbitClient do
    pipe_through :browser
    get "/", CarenAuthController, :index
    get "/callback", CarenAuthController, :callback
  end
end
