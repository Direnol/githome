# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :githome_web,
  namespace: GithomeWeb,
  ecto_repos: [Githome.Repo],
  tmp_ssh: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzc4Zd38XFKwaWvzMCNbNAvM6rO8GDtcR8+Znrs/CY97oN/JcxzIUR73MLFJfAiVw3sEvyyEKTD4oJhsQD6yK/OXmarrSTkXIeCvdKaOoqw56Id4kTd4np1ms2VyOezclAYjhvfpDZacYGf+ZU7Kho024XPhgdr2DZWBObPVNUdXaI+I4dVNXLKfXxNjTNrxZdla6T434LhWcUVIjQPhUW6+/JlE1QSykdM7B+FGdD0iomnVlBcIrWw7AyDQeTqmiBeKtNa4L6vLR3D+/5Y6foIMiHDTODoUjeE6dvfxdTH60U3iK59yzaJVXttLkswP64vxvsjfthuiBQvK1v6VZ9 tmp@03c2126420fd"

# Configures the endpoint
config :githome_web, GithomeWeb.Endpoint,
  server: true,
  url: [host: "localhost"],
  secret_key_base: "L3kLyd6du3zmX2VvOSyxt3GORrLtVz/Z7dgHOUVfsaFJEjpcQ/P73w/xS2KDGOdm",
  render_errors: [view: GithomeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GithomeWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
