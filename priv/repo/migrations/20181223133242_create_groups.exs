defmodule Githome.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string
      add :uid, :integer
      add :pid, :integer
      add :owner, :boolean

      timestamps()
    end
  end
end
