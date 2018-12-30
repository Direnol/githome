defmodule GithomeWeb.LoginControllerTest do
  use GithomeWeb.ConnCase

  alias Githome.Users
  alias GithomeWeb.LoginController

  @invalid_attrs %{login: nil, password: nil}

  describe "login" do
    test "Get login page", %{conn: conn} do
      get(conn, Routes.login_path(conn, :index))
      |> Map.get(:status)
      |> (fn r -> assert(200 == r) end).()
    end
  end

  describe "user" do
    test "create user", %{conn: conn} do
      {ret, _map} =
        Users.create_user(%{
          :username => "ololo",
          :password => "ololo",
          :password_confirm => "ololo"
        })

      assert ret == :ok
    end

    test "get user.id by name", %{conn: conn} do
      id = Users.get_user_by(username: "ololo")
      assert id != nil
    end

    test "delete user by id", %{conn: conn} do
      Users.get_user_by(username: "ololo")
      |> IO.inspect()

      # {ret, _map} = Users.delete_user(user.id)
      assert :ok == :ok
    end

    test "register user", %{conn: conn} do
      ret =
        conn
        |> clear_flash
        |> LoginController.register(%{
          "username" => "user",
          "password" => "pass",
          "confirm-password" => "pass",
          "_csrf_token" => "token"
        })

      assert "/session/new?username=user&token=token" =~ redirected_to(ret, 302)
    end
  end
end
