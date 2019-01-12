defmodule GithomeWeb.UserControllerTest do
  use GithomeWeb.ConnCase

  alias Githome.Users
  import GithomeWeb.Factory
  use PhoenixIntegration

  describe "index" do
    setup do
      admin = insert(:user, admin: true)

      user = insert(:user)

      [admin: admin, user: user]
    end

    test "Not auth", %{conn: conn} do
      get(conn, Routes.user_path(conn, :index))
      |> assert_response(to: Routes.login_path(conn, :index))
    end

    test "Auth", %{conn: conn, user: user, admin: admin} do
      get(build_conn(), "/")
      |> follow_form(%{username: user.username, password: user.password, _csrf_token: "token"},
        identifier: "#login-form"
      )
      |> assert_response(path: "/my_projects")
      |> get(Routes.user_path(conn, :index))
      |> assert_response(path: Routes.user_path(conn, :index), body: "#{user.username}")
      |> assert_response(body: "#{admin.username}")
      |> refute_response(body: "Delete")
    end

    test "As admin", %{conn: conn, user: user, admin: admin} do
      get(build_conn(), "/")
      |> follow_form(%{username: admin.username, password: admin.password, _csrf_token: "token"},
        identifier: "#login-form"
      )
      |> assert_response(path: "/my_projects")
      |> get(Routes.user_path(conn, :index))
      |> assert_response(path: Routes.user_path(conn, :index), body: "#{user.username}")
      |> assert_response(body: "#{admin.username}")
      |> assert_response(body: "Delete")
    end
  end
end
