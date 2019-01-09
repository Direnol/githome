defmodule Githome.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:username, :string, null: false)
      add(:password_digest, :string)
      timestamps()
    end
  end
end
