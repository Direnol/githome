use Mix.Config

config :githome, ecto_repos: [Githome.Repo]

import_config "#{Mix.env()}.exs"
