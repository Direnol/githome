# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :githome,
  ecto_repos: [Githome.Repo]

# Configures the endpoint
config :githome, GithomeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "abexE8mxWuc7a9gXr5oh3Us49iDNEpotfdpM2REdpW7diUhGd9d5mDeb6+CpP1mf",
  render_errors: [view: GithomeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Githome.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
