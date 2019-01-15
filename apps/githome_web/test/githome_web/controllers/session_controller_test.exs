defmodule GithomeWeb.SessionControllerTest do
  use GithomeWeb.ConnCase

  import GithomeWeb.Factory
  use PhoenixIntegration
  import Plug.Test
  alias Phoenix.Token
  alias GithomeWeb.CheckAuth, as: CA

  @sault Application.get_env(:githome_web, :token_sault)

  describe "New session" do
    setup do
      usr = insert(:user)

      [
        auth_tok: Token.sign(GithomeWeb.Endpoint, @sault, %CA{username: usr.username, id: usr.id}),
        auth_expired:
          Token.sign(GithomeWeb.Endpoint, @sault, %CA{username: usr.username, id: usr.id},
            signed_at: System.system_time(:second) - 86500
          ),
        user: usr
      ]
    end

    test "User not exist", %{conn: conn, auth_tok: auth_tok} do
      conn
      |> init_test_session(%{auth_token: auth_tok})
      |> get("/session/new", %{
        username: "bad user",
        token: "token"
      })
      |> assert_response(redirect: Routes.login_path(conn, :index))
    end

    test "User exist", %{conn: conn, auth_tok: auth_tok, user: usr} do
      conn
      |> init_test_session(%{auth_token: auth_tok})
      |> get("/session/new", %{
        username: usr.username,
        token: "token"
      })
      |> assert_response(to: Routes.my_project_path(conn, :index))
    end

    test "User exist, but token expired", %{conn: conn, auth_expired: auth_tok, user: usr} do
      conn
      |> init_test_session(%{auth_token: auth_tok})
      |> get("/session/new", %{
        username: usr.username,
        token: "token"
      })
      |> assert_response(to: Routes.login_path(conn, :index))
    end

    test "User exist, but token is not correct", %{conn: conn, user: usr} do
      conn
      |> init_test_session(%{auth_token: "some token"})
      |> get("/session/new", %{
        username: usr.username,
        token: "token"
      })
      |> assert_response(to: Routes.login_path(conn, :index))
    end
  end

  describe "Old session" do
    setup do
      %{username: username, password: password} = insert(:user)

      uconn =
        get(build_conn(), "/")
        |> follow_form(%{username: username, password: password},
          identifier: "#login-form"
        )
        |> assert_response(path: "/my_projects")

      [username: username, pass: password, uconn: uconn]
    end

    test "logout", %{uconn: conn} do
      conn
      |> assert_response(path: "/my_projects")
      |> get("/session/logout")
      |> assert_response(to: "/")
      |> follow_redirect
      |> get(Routes.my_project_path(conn, :index))
      |> assert_response(to: "/")
    end
  end
end
