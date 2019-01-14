use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :githome_web, GithomeWeb.Endpoint,
  http: [port: 4002],
  server: false

config :phoenix_integration,
  endpoint: GithomeWeb.Endpoint

config :comeonin, bcrypt_log_rounds: 0
