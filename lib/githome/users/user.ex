defmodule Githome.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    field :username, :string
    field :password_digest, :string
    field :description, :string
    field :admin, :boolean
    field :email, :string
    timestamps()

    # Virtual Fields
    field :password, :string, virtual: true
    field :password_confirm, :string, virtual: true
  end

  @cast_params [:username, :password, :password_confirm, :admin, :description, :email]
  @validate_req [:username, :password, :password_confirm]
  @doc false
  def changeset(user, params) do
    user
    |> cast(params, @cast_params)
    |> validate_required(@validate_req)
    |> hash_password
  end

  def hash_password(changeset) do
    if password = get_change(changeset, :password) do
      changeset
      |> put_change(:password_digest, hashpwsalt(password))
    else
      changeset
    end
  end
end
