# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :fitbit_client,
  ecto_repos: [FitbitClient.Repo]

config :oauth2,
  warn_missing_serializer: false

# Configures the endpoint
config :fitbit_client, FitbitClient.Endpoint,
  instrumenters: [Appsignal.Phoenix.Instrumenter],
  url: [host: "localhost"],
  secret_key_base: "lrSGfOxVvir5EPO/EtwRFP/K7F+Q2SETCRfXOhgNlcC9rcaxN4Vpq/u0Vjd95yKM",
  render_errors: [view: FitbitClient.ErrorView, accepts: ~w(html json)],
  pubsub: [name: FitbitClient.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
