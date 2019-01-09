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
      get(build_conn(), "/session/new", Map.replace!(@param, :username, "bad user"))
      |> assert_response(redirect: "/")
    end

    test "User exist" do
      get(build_conn(), "/session/new", @param)
      |> assert_response(redirect: "/my_projects")
    end
  end

  describe "Old session" do
    setup do
      %{username: username} = insert(:user)
      {:ok, username: username}
    end

    test "logout exist session", %{username: username} do
      get(build_conn(), "/session/new", Map.replace!(@param, :username, username))
      |> follow_redirect
      |> assert_response(path: "/my_projects")
      |> get("/session/logout")
      |> assert_response(to: "/")
    end
  end
end
