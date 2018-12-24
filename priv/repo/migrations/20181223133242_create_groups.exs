defmodule Githome.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string
      add :uid, :integer
      add :pid, :integer

      timestamps()
    end
  end
end
