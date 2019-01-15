defmodule GithomeWeb.LoginControllerTest do
  use GithomeWeb.ConnCase

  use PhoenixIntegration
  import GithomeWeb.Factory
  alias Plug.Test, as: PT
  alias GithomeWeb.CheckAuth, as: CA

  @reg_user %{
    username: "user",
    password: "pass",
    confirm: "pass",
    _csrf_token: "token"
  }

  @log_user %{
    username: "user",
    password: "pass",
    _csrf_token: "token"
  }

  describe "Register" do
    test "New user" do
      get(build_conn(), "/")
      |> follow_form(@reg_user, identifier: "#register-form")
      |> assert_response(path: "/my_projects")
    end

    test "Incorrect confirm pass" do
      get(build_conn(), "/")
      |> follow_form(Map.replace!(@reg_user, :password, "pas"), identifier: "#register-form")
      |> assert_response(path: "/", assigns: %{info: "Check your password"})
    end

    test "Already exist" do
      usr = insert(:user)
      get(build_conn(), "/")
      |> follow_form(%{
        username: usr.username,
        password: usr.password,
        confirm: usr.password_confirm,
        _csrf_token: "token"
      }, identifier: "#register-form")
      |> assert_response(status: 200, path: "/", assigns: %{info: "Already exist"})
    end
  end

  describe "Login" do
    setup do
      post(build_conn(), "/register", @reg_user)
      :ok
    end

    test "Auth" do
      get(build_conn(), "/")
      |> follow_form(@log_user, identifier: "#login-form")
      |> assert_response(path: "/my_projects")
    end

    test "Bad Auth: nouser" do
      get(build_conn(), "/")
      |> follow_form(Map.replace!(@log_user, :username, "nouser"), identifier: "#login-form")
      |> assert_response(path: "/", assigns: %{info: "Incorrected password or username."})
    end

    test "Bad Auth: incorrect pass" do
      get(build_conn(), "/")
      |> follow_form(Map.replace!(@log_user, :password, "pas"), identifier: "#login-form")
      |> assert_response(path: "/", assigns: %{info: "Incorrected password or username."})
    end
  end

  @sault Application.get_env(:githome_web, :token_sault)

  describe "Restore old session" do
    setup do
      user = insert(:user)
      [
        auth_tok: Phoenix.Token.sign(GithomeWeb.Endpoint, @sault, %CA{username: user.username, id: user.id}),
        bad_tok: Phoenix.Token.sign(GithomeWeb.Endpoint, @sault, %CA{username: "not_register"})
      ]
    end

    test "Session is restored", %{auth_tok: auth_tok, conn: conn} do
      conn
      |> PT.init_test_session(%{auth_token: auth_tok})
      |> get(Routes.login_path(conn, :index))
      |> follow_redirect
      |> assert_response(status: 200, path: Routes.my_project_path(conn, :index))
    end

    test "Session is not restored, because user not exist", %{bad_tok: auth_tok, conn: conn} do
      conn
      |> PT.init_test_session(%{auth_token: auth_tok})
      |> get(Routes.login_path(conn, :index))
      |> follow_redirect
      |> assert_response(status: 200, path: Routes.login_path(conn, :index))
    end

    test "Session is not restored", %{conn: conn} do
      conn
      |> PT.init_test_session(%{auth_token: "bad token"})
      |> get(Routes.login_path(conn, :index))
      |> follow_redirect
      |> assert_response(path: Routes.login_path(conn, :index))
    end
  end
end
