defmodule Caren do
  use OAuth2.Strategy
  alias OAuth2.Strategy.AuthCode

  def client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: System.get_env("CAREN_CLIENT_ID"),
      client_secret: System.get_env("CAREN_CLIENT_SECRET"),
      redirect_uri: System.get_env("CAREN_REDIRECT_URI"),
      site: "https://www.carenzorgt.nl",
      authorize_url: "https://www.carenzorgt.nl/login/oauth/authorize",
      token_url: "https://www.carenzorgt.nl/oauth/token"
    ])
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
    |> put_header("accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end

end
