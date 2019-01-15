defmodule GithomeWeb.GroupController do
  use GithomeWeb, :controller

  alias Githome.GroupInfo.Ginfo
  alias Githome.GroupInfo
  alias Githome.Users

  plug :put_layout, "main.html"

  def index(conn, _params) do
    user = get_session(conn, :user)
    groups = GroupInfo.list_ginfos()
    user_update = Users.get_user!(user.id)

    conn
    |> put_session(:user, user_update)
    |> put_session(:nav_active, :groups_view_all)
    |> render("index.html",
      groups: groups,
      layout: {GithomeWeb.LayoutView, "main.html"},
      user: user_update,
      nav_active: :groups_view_all
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

    user_update = Users.get_user!(user.id)

    conn
    |> put_session(:user, user_update)
    |> put_session(:nav_active, :groups)
    |> render("new.html",
      changeset: changeset,
      layout: {GithomeWeb.LayoutView, "main.html"},
      users: list_of_users,
      user: user_update,
      nav_active: :groups,
      token: get_session(conn, :token)
    )
  end

  def create(conn, params) do
    group_params = params["group"]

    case GroupInfo.create_ginfo(group_params) do
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
    group = GroupInfo.get_ginfo!(id)
    render(conn, "show.html", group: group)
  end

  def edit(conn, %{"id" => id}) do
    group = GroupInfo.get_ginfo!(id)
    changeset = GroupInfo.change_ginfo(group)
    render(conn, "edit.html", group: group, changeset: changeset)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = GroupInfo.get_ginfo!(id)

    case GroupInfo.update_ginfo(group, group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group updated successfully.")
        |> redirect(to: Routes.group_path(conn, :show, group))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", group: group, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = GroupInfo.get_ginfo!(id)
    {:ok, _group} = GroupInfo.delete_ginfo(group)

    conn
    |> put_flash(:info, "Group deleted successfully.")
    |> redirect(to: Routes.group_path(conn, :index))
  end
end
