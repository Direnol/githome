defmodule Githome.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :gid, :integer
    field :uid, :integer
    field :owner, :boolean

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:uid, :gid, :owner])
    |> validate_required([:uid, :gid, :owner])
  end
end
