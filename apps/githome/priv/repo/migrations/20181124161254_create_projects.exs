defmodule Githome.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :project_name, :string
      add :description, :string
      add :owner, :integer

      timestamps()
    end
  end
end
