defmodule Githome.Members.Member do
  use Ecto.Schema
  import Ecto.Changeset

  schema "members" do
    field(:gid, :integer)
    field(:uid, :integer)
    field(:owner, :boolean)

    timestamps()
  end

  @cast_param [:uid, :gid, :owner]
  @validate_param @cast_param
  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, @cast_param)
    |> validate_required(@validate_param)
  end
end
