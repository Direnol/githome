defmodule GithomeWeb.SessionControllerTest do
  use GithomeWeb.ConnCase

  alias Githome.Users
  alias String
  import GithomeWeb.SessionController

  @param %{token: "ITc3PC05Ek9nDBMCIGcpKhQBFz9yEAAAnQqeDvU8LKkar3ekV5tM+A==", username: "ololo"}

  describe "Session" do
    test "create new session", %{conn: conn} do
      new(conn, @param)
      |> Map.get(:status)
      |> (fn r -> assert(302 == r) end).()
    end
  end
end
