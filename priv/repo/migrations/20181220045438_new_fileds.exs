defmodule Githome.Repo.Migrations.NewFileds do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :description, :string
      add :email, :string, default: "nomail"
    end
  end
end
