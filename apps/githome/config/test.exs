use Mix.Config

# Configure your database
config :githome, Githome.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: System.get_env("DB_USER") || "githome",
  password: System.get_env("DB_PASS") || "githome",
  database: System.get_env("DB_NAME") || "githome_test",
  hostname: System.get_env("DB_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
