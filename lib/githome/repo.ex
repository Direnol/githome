defmodule Githome.Repo do
  use Ecto.Repo,
    otp_app: :githome,
    adapter: Ecto.Adapters.MySQL
end
