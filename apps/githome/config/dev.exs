use Mix.Config

# Configure your database
config :githome, Githome.Repo,
  username: System.get_env("DB_USER") || "githome",
  password: System.get_env("DB_PASS") || "githome",
  database: System.get_env("DB_NAME") || "githome",
  hostname: System.get_env("DB_HOST") || "localhost",
  pool_size: 10
