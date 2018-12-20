defmodule GithomeWeb.PageController do
  use GithomeWeb, :controller

  alias Githome.Users
  alias Githome.Users.User

  plug :put_layout, "main.html"

  def index(conn, _params) do
    token = get_session(conn, :token)
    case token  do
      nil ->
          conn
            |> put_flash(:info, "Please sign in")
            |> redirect(to: Routes.login_path(conn, :index))
      _ ->
        username = get_session(conn, :username)
        user = Users.get_user_by(username: username)
        if user == nil do
          redirect(conn, to: Routes.login_path(conn, :index))
        end
        redirect(conn, to: Routes.project_path(conn, :index))
    end
  end
end
