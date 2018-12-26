defmodule Githome.Repo.Migrations.CreateGroupProject do
  use Ecto.Migration

  def change do
    create table(:group_project) do
      add :pid, :integer
      add :gid, :integer

      timestamps()
    end

  end
end
