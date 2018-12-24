defmodule Githome.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :name, :string
    field :pid, :integer
    field :uid, :integer

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :uid, :pid])
    |> validate_required([:name, :uid, :pid])
  end

  def changeset_private_group(group, attrs) do
    group
    |> cast(attrs, [:name, :uid, :pid])
    |> validate_required([:name, :uid])
  end
end
