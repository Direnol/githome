defmodule Githome.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :project_name, :string
      add :path_to_directory, :string

      timestamps()
    end
  end
end
