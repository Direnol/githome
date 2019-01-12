defmodule GithomeWeb.ParameterControllerTest do
  use GithomeWeb.ConnCase

  alias Githome.Settrings
  import GithomeWeb.Factory
  use PhoenixIntegration

  @create_attrs %{key: "some key", value: "some value"}
  @update_attrs %{key: "some updated key", value: "some updated value"}
  @invalid_attrs %{key: nil, value: nil}

  def fixture(:parameter) do
    {:ok, parameter} = Settrings.create_parameter(@create_attrs)
    parameter
  end

  describe "index" do
    setup do
      admin = insert(:user, admin: true)

      user = insert(:user)

      [admin: admin, user: user]
    end
    test "lists all settings as not admin", %{user: user} do
      get(build_conn(), "/")
      |> follow_form(%{
                         username: user.username,
                         password: user.password,
                         _csrf_token: "token"
                      }, identifier: "#login-form")
      |> assert_response(path: "/my_projects")
      |> get(Routes.parameter_path(conn, :index))
      |> assert_response(to: Routes.login_path(conn, :index))
    end

    test "lists all settings as admin", %{admin: admin} do
      get(build_conn(), "/")
      |> follow_form(%{
        username: admin.username,
        password: admin.password,
        _csrf_token: "token"
      }, identifier: "#login-form")
      |> assert_response(path: "/my_projects")
      |> get(Routes.parameter_path(conn, :index))
      |> assert_response(path: "/settings")
    end
  end
end
