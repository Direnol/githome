defmodule Githome.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add(:gid, :integer)
      add(:uid, :integer)
      add(:owner, :boolean)

      timestamps()
    end
  end
end
