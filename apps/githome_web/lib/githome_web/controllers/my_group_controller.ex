defmodule GithomeWeb.MyGroupController do
  use GithomeWeb, :controller

  alias Githome.GroupInfo.Ginfo
  alias Githome.GroupInfo
  alias Githome.Members
  alias Githome.Users
  alias Githome.Projects
  alias Githome.GroupProject
  alias GithomeWeb.GitController, as: Git
  alias Githome.GroupProject
  plug :put_layout, "main.html"

  def index(conn, _params) do
    user = get_session(conn, :user)

    groups = Members.list_my_groups(user.id)
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
  end

  def new(conn, _params) do
    user = get_session(conn, :user)

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
  end

  defp set_group(group, uname, owner_id, members, projects) do
    Git.create_group(
      group.name,
      Enum.map([owner_id] ++ members, fn x ->
        Users.get_user!(x).username
      end)
    )

    Enum.map(
      projects,
      fn p ->
        Git.update_project(Projects.get_project!(p).project_name,
          RW:
            [uname, "@#{group.name}"] ++
              Enum.map(Githome.Projects.get_groups_by_project(p), fn x ->
                "@#{x.name}"
              end)
        )
      end
    )
  end

  def create(conn, params) do
    owner_id = get_session(conn, :user).id

    g_params =
      params["ginfo"]
      |> Map.put("owner", owner_id)

    case Members.create_group(g_params) do
      {:ok, group} ->
        set_group(
          group,
          get_session(conn, :user).username,
          owner_id,
          g_params["members"] || [],
          g_params["projects"] || []
        )

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
    members = Members.get_all_members_by_group(group.id)
    projects = GroupProject.get_all_project_by_group(group.id)

    conn
    |> render("show.html",
      group: group,
      members: members,
      projects: projects,
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
      id: %{"id" => group},
      changeset: changeset,
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
    group_params = params["ginfo"]
    group = GroupInfo.get_ginfo!(id)
    owner_id = get_session(conn, :user).id
    old_projects = Enum.map(GroupProject.get_all_project_by_group(id), fn x -> "#{x.id}" end)
    projects = group_params["projects"] || []

    Enum.map(old_projects -- projects, fn x ->
      update_projects([Projects.get_project_by(project_name: x)])
    end)

    case GroupInfo.update_ginfo(group, group_params) do
      {:ok, group} ->
        set_group(
          group,
          get_session(conn, :user).username,
          owner_id,
          group_params["members"] || [],
          projects
        )

        conn
        |> put_flash(:info, "Group updated successfully.")
        |> redirect(to: Routes.my_group_path(conn, :show, %{"id" => id}))

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:info, "Group not updated.")
        |> redirect(to: Routes.my_group_path(conn, :edit, %{"id" => id}))
    end
  end

  defp update_projects([nil]), do: nil

  defp update_projects(projects) do
    Enum.map(projects, fn p ->
      members = Enum.map(Projects.get_groups_by_project(p.id), fn x -> "@#{x.name}" end)
      Git.update_project(p.project_name, RW: [Users.get_user!(p.owner).username | members])
    end)
  end

  def delete(conn, %{"id" => id}) do
    group = GroupInfo.get_ginfo!(id)
    projects = GroupProject.get_all_project_by_group(id)
    Git.delete_group(group.name)
    Members.delete_group(id)

    update_projects(projects)

    conn
    |> put_flash(:info, "Group deleted successfully.")
    |> redirect(to: Routes.my_group_path(conn, :index))
  end
end
