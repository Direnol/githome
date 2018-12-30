use Mix.Config

# Configure your database
config :githome, Githome.Repo,
  username: "githome",
  password: "githome",
  database: "githome",
  hostname: "localhost",
  pool_size: 10
