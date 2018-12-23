defmodule GithomeWeb.MyProjectController do
  use GithomeWeb, :controller

  alias Githome.Projects
  alias Githome.Projects.Project
  alias Githome.Users

  plug :put_layout, "main.html"

  def index(conn, _params) do
    token = get_session(conn, :token)
    case token  do
      nil ->
        conn
        |> put_flash(:info, "Please sign in")
        |> redirect(to: Routes.login_path(conn, :index))
      _ ->
        user = get_session(conn, :user)
        case is_map(user) do
          true ->
            user_update = Users.get_user!(user.id)
            projects = Projects.list_projects()
            conn
              |> put_session(:user, user_update)
              |> put_session(:nav_active, :projects_view_my)
              |> render("index.html", projects: projects, layout: {GithomeWeb.LayoutView, "main.html"}, user: user_update, nav_active: :projects_view_my)
          _ ->
            conn
              |> put_flash(:info, "Please sign in")
              |> redirect(to: Routes.login_path(conn, :index))
        end
      end
  end

  def add(conn, _params) do
    token = get_session(conn, :token)
    case token  do
      nil ->
        conn
        |> put_flash(:info, "Please sign in")
        |> redirect(to: Routes.login_path(conn, :index))
      _ ->
        user = get_session(conn, :user)
        if user == nil do
          conn
          |> put_flash(:info, "Please sign in")
          |> redirect(to: Routes.login_path(conn, :index))
        end
        projects = Projects.list_projects()
        conn = put_session(conn, :nav_active, :projects_add_new)
        conn
        |> render("add.html", projects: projects, layout: {GithomeWeb.LayoutView, "main.html"}, user: get_session(conn, :user), nav_active: get_session(conn, :nav_active))
    end
  end
end
