defmodule Githome.GroupInfo.Ginfo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "group_info" do
    field :description, :string
    field :name, :string

    timestamps()
  end

  @cast_param [:name, :description]
  @validate_param [:name]
  @doc false
  def changeset(group_info, attrs) do
    group_info
    |> cast(attrs, @cast_param)
    |> validate_required(@validate_param)
  end
end
