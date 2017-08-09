# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :core,
  ecto_repos: [Core.Repo]

# Configures the endpoint
config :core, Core.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "61GK+1WYLfa/CZWMp7weml9EKWbhz2TD+OD7QHqxx4pEiD5ZQgJjYzcG/SvGkXVi",
  render_errors: [view: Core.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Core.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :ueberauth, Ueberauth,
  providers: [
    identity: {Ueberauth.Strategy.Identity, [
      callback_methods: ["POST"],
      uid_field: :username,
      nickname_field: :username,
    ]}
  ]

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "Core",
  ttl: {30, :days},
  allowed_drift: 2000,
  verify_issuer: true, # optional
  secret_key: "C+XnZx8nnSmHN87wRwGA99WPb3tieVDSFuWsGW6T0WgcwETQt/8g6lsRGELv9lLZ",
  serializer: GuardianSerializer

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
