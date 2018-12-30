defmodule Githome.GroupProject.Gp do
  use Ecto.Schema
  import Ecto.Changeset

  schema "group_project" do
    field :gid, :integer
    field :pid, :integer

    timestamps()
  end

  @cast_param [:pid, :gid]
  @validate_param @cast_param
  @doc false
  def changeset(group_project, attrs) do
    group_project
    |> cast(attrs, @cast_param)
    |> validate_required(@validate_param)
  end
end
