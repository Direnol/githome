defmodule Githome.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :project_name, :string

      timestamps()
    end
  end
end
