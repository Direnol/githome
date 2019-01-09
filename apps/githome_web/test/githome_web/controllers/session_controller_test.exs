defmodule GithomeWeb.SessionControllerTest do
  use GithomeWeb.ConnCase

  alias Githome.Users
  alias String

  @param %{token: "ITc3PC05Ek9nDBMCIGcpKhQBFz9yEAAAnQqeDvU8LKkar3ekV5tM+A==", username: "user"}

  setup do
    insert(:user, username: @param.username)
    :ok
  end

  describe "New session" do
    test "User not exist" do
      ret = get(build_conn(), "/session/new", Map.replace!(@param, :username, "bad user"))
      assert redirected_to(ret, 302) == "/"
    end

    test "User exist" do
      ret = get(build_conn(), "/session/new", @param)
      assert "/my_projects" == redirected_to(ret, 302)
    end
  end

  describe "Old session" do
    setup do
      %{username: username} = insert(:user)
      {:ok, username: username}
    end

    test "logout exist session", %{username: username} do
      has_conn =
        get(build_conn(), "/session/new", Map.replace!(@param, :username, username))
        |> follow_redirect
        |> assert_response(path: "/my_projects")

      get(has_conn, "/session/logout")
      |> follow_redirect
      |> assert_response(path: "/")
    end
  end
end
