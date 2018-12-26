defmodule Githome.GroupInfo.Group do
  use Ecto.Schema
  import Ecto.Changeset


  schema "group_info" do
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(group_info, attrs) do
    group_info
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
