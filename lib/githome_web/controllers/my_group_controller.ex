defmodule GithomeWeb.MyGroupController do
  use GithomeWeb, :controller

  alias Githome.GroupInfo.Ginfo
  alias Githome.GroupInfo
  alias Githome.Groups
  alias Githome.Users
  alias Githome.Projects
  alias Githome.GroupProject

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
            changeset = GroupInfo.change_ginfo(%Ginfo{})
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
              info: get_flash(conn, :info),
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
    g_params = params["ginfo"]
    g_params = Map.put(g_params, "owner", get_session(conn, :user).id)
    case Groups.create_group(g_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group created successfully.")
        |> redirect(to: Routes.my_group_path(conn, :show, %{"id" => group.id}))

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:info, "Group not created.")
        |> redirect(to: Routes.my_group_path(conn, :new))
    end
  end

  def show(conn, %{"id" => id}) do
    group = GroupInfo.get_ginfo!(id)
    members = Groups.get_all_members_by_group group.id
    projects = GroupProject.get_all_project_by_group group.id
    conn
    |> render("show.html",
            group: group, members: members, projects: projects,
            layout: {GithomeWeb.LayoutView, "main.html"},
            user: get_session(conn, :user),
            info: get_flash(conn, :info),
            nav_active: get_session(conn, :nav_active)
            )
  end

  def edit(conn, %{"id" => id}) do
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

    group = GroupInfo.get_ginfo!(id)
    changeset = GroupInfo.change_ginfo(group)
    conn
      |> render("edit.html",
            id: %{"id" => group}, changeset: changeset,
            layout: {GithomeWeb.LayoutView, "main.html"},
            user: get_session(conn, :user),
            users: list_of_users,
            projects: list_of_projects,
            info: get_flash(conn, :info),
            nav_active: get_session(conn, :nav_active)
          )
  end

  def update(conn, params) do
    id = params["id"]
    group_params =params["ginfo"]
    group = GroupInfo.get_ginfo!(id)

    case GroupInfo.update_ginfo(group, group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group updated successfully.")
        |> redirect(to: Routes.my_group_path(conn, :show, %{"id" => id}))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:info, "Group not updated.")
        |> redirect(to: Routes.my_group_path(conn, :edit, %{"id" => id}))
    end
  end

  def delete(conn, %{"id" => id}) do
    group = GroupInfo.get_ginfo!(id)
    {:ok, _group} = Groups.delete_group(group)

    conn
    |> put_flash(:info, "Group deleted successfully.")
    |> redirect(to: Routes.group_path(conn, :index))
  end
end
