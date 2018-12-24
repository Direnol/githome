defmodule GithomeWeb.LoginControllerTest do
  use GithomeWeb.ConnCase
  #get csrf token

  alias Githome.Users
  import GithomeWeb.LoginController

  @invalid_attrs %{login: nil, password: nil}

  describe "login" do
    test "Get login page", %{conn: conn} do
      get(conn, Routes.login_path(conn, :index))
      |> Map.get(:status)
      |> (fn (r) -> assert(200 == r) end).()
    end
  end

  describe "user" do
	test "create user", %{conn: conn} do
	  {ret, _map} = Users.create_user( %{
		:username => "ololo",
		:password => "ololo",
		:password_confirmation => "ololo" 
	  });
	  assert ret == :ok
	end
  
	test "get user.id by name", %{conn: conn} do
	  id = Users.get_user_by(username: "ololo")
	  assert id != nil
	end

	test "delete user by id", %{conn: conn} do
	  Users.delete_user(Users.get_user_by(username: "ololo"));
	  id1 = Users.get_user_by(username: "ololo")
	  assert id1 == nil
	end
  end
end
