defmodule GithomeWeb.SessionController do
  use GithomeWeb, :controller

  alias Githome.Users
  alias String

  def new(conn, params) do
    token = params["token"]
    username = params["username"]

    case Users.get_user_by(username: username) do
      nil ->
        conn
        |> redirect(to: Routes.login_path(conn, :index))

      user ->
        conn
        |> put_session(:token, token)
        |> put_session(:user, user)
        |> redirect(to: Routes.my_project_path(conn, :index))
    end
  end

  def logout(conn, _) do
    conn
    |> clear_session()
    |> redirect(to: Routes.login_path(conn, :index))
  end
end
