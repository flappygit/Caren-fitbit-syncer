defmodule Caren do
  use OAuth2.Strategy
  alias OAuth2.Strategy.AuthCode

  def client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: System.get_env("58982edd7cb0739922f4ddab200686fd1ddde110c67068590357a8256c77770d"),
      client_secret: System.get_env("dfaf0e694d60e26d1c0f7e559a59b19b73e495dd5490572dec2954225cbafe80"),
      redirect_uri: System.get_env("https://www.carenzorgt.nl/"),
      site: "http://localhost:3005",
      authorize_url: "http://localhost:3005/login/oauth/authorize",
      token_url: "http://developer.caren.dev:3005/oauth/token"
    ])
  end

  def redirect_url do
    OAuth2.Client.authorize_url!(client(), scope: "user.read")
  end

  def authorize_url!(params \\ []) do
    OAuth2.Client.authorize_url!(client(), params)
  end

  def get_token(params \\ [], headers \\ []) do
    OAuth2.Client.get_token!(client(), params, headers)
  end

  # Strategy Callbacks:
  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client().client_secret)
    |> AuthCode.get_token(params, headers)
  end

end
