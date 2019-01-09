defmodule Githome.Repo.Migrations.CreateGroupInfo do
  use Ecto.Migration

  def change do
    create table(:group_info) do
      add(:name, :string)
      add(:description, :string)

      timestamps()
    end
  end
end
