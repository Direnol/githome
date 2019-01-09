defmodule Githome.Settings.Parameter do
  use Ecto.Schema
  import Ecto.Changeset

  schema "settings" do
    field(:key, :string)
    field(:value, :string)

    timestamps()
  end

  @doc false
  def changeset(parameter, attrs) do
    parameter
    |> cast(attrs, [:key, :value])
    |> validate_required([:key, :value])
  end
end
