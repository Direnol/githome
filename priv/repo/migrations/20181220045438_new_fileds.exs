defmodule Githome.Repo.Migrations.NewFileds do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :avatar_uri, :string
      add :email, :string, default: "nomail"
    end
  end
end
