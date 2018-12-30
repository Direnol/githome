defmodule Githome.Repo do
  use Ecto.Repo, otp_app: :githome, adapter: Ecto.Adapters.MySQL

  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end
end
