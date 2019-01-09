defmodule Githome.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    field(:username, :string)
    field(:password_digest, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:admin, :boolean)
    field(:avatar_uri, :string)
    field(:email, :string)
    field(:ssh_key, :string)
    timestamps()

    # Virtual Fields
    field(:password, :string, virtual: true)
    field(:password_confirm, :string, virtual: true)
  end

  @cast_params [
    :username,
    :password,
    :password_confirm,
    :admin,
    :first_name,
    :last_name,
    :avatar_uri,
    :email,
    :ssh_key
  ]
  @validate_req_create [:username, :password, :password_confirm]
  @validate_req_change_pass [:password]
  @doc false
  def changeset(user, params) do
    user
    |> cast(params, @cast_params)
    |> validate_required(@validate_req_create)
    |> hash_password
  end

  def changeset_customize(user, params) do
    user
    |> cast(params, @cast_params)
  end

  def changeset_req_change_pass(user, params) do
    user
    |> cast(params, @cast_params)
    |> validate_required(@validate_req_change_pass)
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
