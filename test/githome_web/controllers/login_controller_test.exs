defmodule GithomeWeb.LoginControllerTest do
  use GithomeWeb.ConnCase

  test "Open login page /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ ~r("Register|Login")
  end
end
