defmodule Githome.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :name, :string
    field :pid, :integer
    field :uid, :integer
    field :owner, :boolean

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :uid, :pid, :owner])
    |> validate_required([:name, :uid, :pid, :owner])
  end
end
