defmodule GithomeWeb.SessionController do
  use GithomeWeb, :controller

  alias Githome.Users
  alias Githome.Users.User
  alias String

  def new(conn, params) do
    token = params["token"]
    username = params["username"]
    case String.valid?(token) do
      true ->
        conn
          |> put_session(:token, token)
          |> put_session(:username, username)
          |> redirect(to: Routes.page_path(conn, :index))
      _ ->
        conn
           |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def logout(conn, params) do
    conn
      |> clear_session()
      |> redirect(to: Routes.login_path(conn, :index))
  end
end