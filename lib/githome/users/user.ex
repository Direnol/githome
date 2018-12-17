defmodule Githome.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    field :username, :string
    field :password_digest, :string

    timestamps()

    # Virtual Fields
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
  end

  @doc false
  def changeset(user, params) do
    user
    |> cast(params, [:username, :password, :password_confirmation])
    |> validate_required([:username, :password, :password_confirmation])
    |> hash_password
  end

  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      changeset
      |> put_change(:password_digest, hashpwsalt(password))
    else
      changeset
    end
  end
end