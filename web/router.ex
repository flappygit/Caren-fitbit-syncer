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

  scope "/auth", FitbitClient do
    pipe_through :browser
    get "/", AuthController, :index
    get "/callback", AuthController, :callback
  end
end
