defmodule Githome.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :project_name, :string
    field :description, :string
    field :owner, :integer

    timestamps()
  end
  @cast_param [:project_name, :description, :owner]
  @validate_param [:project_name, :owner]
  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, @cast_param)
    |> validate_required(@validate_param)
  end
end
