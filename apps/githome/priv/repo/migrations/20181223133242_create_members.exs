defmodule Githome.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members) do
      add(:gid, :integer)
      add(:uid, :integer)
      add(:owner, :boolean)

      timestamps()
    end
  end
end
