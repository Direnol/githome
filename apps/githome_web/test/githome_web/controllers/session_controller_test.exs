defmodule GithomeWeb.SessionControllerTest do
  use GithomeWeb.ConnCase

  import Githome.Factory
  alias Githome.Users
  alias String

  @param %{token: "ITc3PC05Ek9nDBMCIGcpKhQBFz9yEAAAnQqeDvU8LKkar3ekV5tM+A==", username: "user"}

  setup do
    insert(:user, username: @param.username)
    :ok
  end
  describe "New session" do
    test "User not exist" do
      insert(:user, admin: true)
      Githome.Users.list_users |> IO.inspect
      ret = get(build_conn(), "/session/new", Map.replace!(@param, :username, "bad user"))
      assert redirected_to(ret, 302) == "/"
    end

    test "User exist" do
      ret = get(build_conn(), "/session/new", @param)
      assert "/my_projects" == redirected_to(ret, 302)
    end
  end
end
