defmodule Githome.UsersTest do
  use Githome.DataCase, async: true

  alias Githome.Users

  @valid_attrs %{
    email: "test@noemail.com",
    password_confirm: "pass",
    password: "pass",
    username: "user_test"
  }
  @update_attrs %{
    email: "foobar@noemail.net",
    username: "foobaar"
  }
  @update_pass %{
    password: "new_pass",
    password_confirm: "new_pass"
  }

  @invalid_attrs %{email: nil, password_confirm: nil, password: nil, username: nil}

  describe "Empty database" do
    setup do
      Githome.Repo.delete_all(Users.User)
      :ok
    end

    test "List users must be empty" do
      assert [] == Users.list_users()
    end

    test "Create user" do
      {ret, _} = Users.create_user(@valid_attrs)
      assert ret == :ok
    end

    test "Create invalid user" do
      {ret, _} = Users.create_user(@invalid_attrs)
      refute ret == :ok
    end
  end

  describe "Database with users" do
    setup do
      {:ok, user} = Users.create_user(@valid_attrs)
      {:ok, user: user}
    end

    test "Get user by: username = #{@valid_attrs.username}" do
      user = Users.get_user_by(username: "#{@valid_attrs.username}")
      assert user.username == @valid_attrs.username
    end

    test "Delete #{@valid_attrs.username}", context do
      Users.delete_user(context.user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(context.user.id) end
    end

    test "Update attributes", context do
      {:ok, _} = Users.update_user_info(context.user, @update_attrs)
      assert Users.get_user!(context.user.id).username == @update_attrs.username
      assert Users.get_user!(context.user.id).email == @update_attrs.email
      assert Users.get_user!(context.user.id).password == @valid_attrs.password
    end

    test "Update password", context do
      {:ok, _} = Users.update_user_pass(context.user, @update_pass)
      assert Users.get_user!(context.user.id).password == @update_pass.password
    end
  end
end
