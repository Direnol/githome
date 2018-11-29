defmodule Githome.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :path_to_directory, :string
    field :project_name, :string

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:project_name, :path_to_directory])
    |> validate_required([:project_name, :path_to_directory])
  end
end
