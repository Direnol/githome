defmodule GithomeWeb.MyGroupController do
  use GithomeWeb, :controller

  alias Githome.GroupInfo.Ginfo
  alias Githome.GroupInfo
  alias Githome.Groups
  alias Githome.Users
  alias Githome.Projects

  plug :put_layout, "main.html"

  def index(conn, _params) do
    token = get_session(conn, :token)

    case token do
      nil ->
        conn
        |> put_flash(:info, "Please sign in")
        |> redirect(to: Routes.login_path(conn, :index))

      _ ->
        user = get_session(conn, :user)

        case is_map(user) do
          true ->
            groups = Groups.list_my_groups(user.id)
            user_update = Users.get_user!(user.id)

            conn
            |> put_session(:user, user_update)
            |> put_session(:nav_active, :groups_view_my)
            |> render("index.html",
              groups: groups,
              layout: {GithomeWeb.LayoutView, "main.html"},
              user: user_update,
              nav_active: :groups_view_my
            )

          _ ->
            conn
            |> put_flash(:info, "Please sign in")
            |> redirect(to: Routes.login_path(conn, :index))
        end
    end
  end

  def new(conn, _params) do
    token = get_session(conn, :token)

    case token do
      nil ->
        conn
        |> put_flash(:info, "Please sign in")
        |> redirect(to: Routes.login_path(conn, :index))

      _ ->
        user = get_session(conn, :user)

        case is_map(user) do
          true ->
            changeset = Groups.change_group(%Ginfo{})
            users = Users.list_users()

            list_of_users =
              for %{username: username, id: id} <- users do
                {username, id}
              end

            projects = Projects.list_projects()

            list_of_projects =
              for %{project_name: project_name, id: id} <- projects do
                {project_name, id}
              end

            user_update = Users.get_user!(user.id)

            conn
            |> put_session(:user, user_update)
            |> put_session(:nav_active, :groups_add_new)
            |> render("new.html",
              changeset: changeset,
              layout: {GithomeWeb.LayoutView, "main.html"},
              users: list_of_users,
              projects: list_of_projects,
              user: user_update,
              nav_active: :groups_add_new,
              token: get_session(conn, :token)
            )

          _ ->
            conn
            |> put_flash(:info, "Please sign in")
            |> redirect(to: Routes.login_path(conn, :index))
        end
    end
  end

  def create(conn, params) do
    group_params = params["group"]

    case Groups.create_group(group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group created successfully.")
        |> redirect(to: Routes.group_path(conn, :show, group))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render("new.html",
          changeset: changeset,
          layout: {GithomeWeb.LayoutView, "main.html"},
          user: get_session(conn, :user),
          nav_active: :groups,
          token: get_session(conn, :token)
        )
    end
  end

  def show(conn, %{"id" => id}) do
    group = Groups.get_group!(id)
    render(conn, "show.html", group: group)
  end

  def edit(conn, %{"id" => id}) do
    group = Groups.get_group!(id)
    changeset = Groups.change_group(group)
    render(conn, "edit.html", group: group, changeset: changeset)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Groups.get_group!(id)

    case Groups.update_group(group, group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group updated successfully.")
        |> redirect(to: Routes.group_path(conn, :show, group))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", group: group, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = Groups.get_group!(id)
    {:ok, _group} = Groups.delete_group(group)

    conn
    |> put_flash(:info, "Group deleted successfully.")
    |> redirect(to: Routes.group_path(conn, :index))
  end
end
