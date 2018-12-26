defmodule Githome.GroupProject.Gp do
  use Ecto.Schema
  import Ecto.Changeset


  schema "group_project" do
    field :gid, :integer
    field :pid, :integer

    timestamps()
  end

  @doc false
  def changeset(group_project, attrs) do
    group_project
    |> cast(attrs, [:pid, :gid])
    |> validate_required([:pid, :gid])
  end
end
