defmodule GithomeWeb.MyProjectController do
  use GithomeWeb, :controller

  alias Githome.Projects
  alias Githome.Projects.Project
  alias Githome.Users
  alias GithomeWeb.GitController, as: Git
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
            user_update = Users.get_user!(user.id)
            projects = Projects.list_my_projects(user.id)
              |> IO.inspect
            conn
            |> put_session(:user, user_update)
            |> put_session(:nav_active, :projects_view_my)
            |> render("index.html",
              projects: projects,
              layout: {GithomeWeb.LayoutView, "main.html"},
              user: user_update,
              nav_active: :projects_view_my
            )

          _ ->
            conn
            |> put_flash(:info, "Please sign in")
            |> redirect(to: Routes.login_path(conn, :index))
        end
    end
  end

  def show(conn, params) do
    id = params["id"]
    path = params["path"] || ""
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
            user_update = Users.get_user!(user.id)
            project = Projects.get_project!(id)

            branches =
              try do
                Git.git_branches(project.project_name)
              rescue
                e ->
                  IO.inspect(e)
                  []
              end

            branch = params["branch"] || branches[:cur_branch]

            files =
              try do
                Git.git_ls(
                  project.project_name,
                  branch,
                  path
                )
              rescue
                e ->
                  IO.inspect(e)
                  []
              end
              |> IO.inspect()

            back =
              if path != "" do
                [{:back, Path.expand(path <> "/../", "") |> String.slice(1..-1)}]
              else
                []
              end

            conn
            |> put_session(:user, user_update)
            |> put_session(:nav_active, :projects_view_my)
            |> render("show.html",
              project: project,
              files: back ++ files,
              layout: {GithomeWeb.LayoutView, "main.html"},
              user: user_update,
              nav_active: :projects_view_my,
              path: path,
              branches: branches,
              branch: branch
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

        if user == nil do
          conn
          |> put_flash(:info, "Please sign in")
          |> redirect(to: Routes.login_path(conn, :index))
        end

        conn = put_session(conn, :nav_active, :projects_add_new)
        changeset = Projects.change_project(%Project{})

        conn
        |> render("new.html",
          layout: {GithomeWeb.LayoutView, "main.html"},
          changeset: changeset,
          user: get_session(conn, :user),
          nav_active: get_session(conn, :nav_active)
        )
    end
  end

  def create(conn, params) do
    user = get_session(conn, :user)
    project_params = params["project"]
      |> Map.put("owner", user.id)
      |> IO.inspect
    case Projects.create_project project_params do
      {:ok, project} ->
        Git.create_project(project.project_name, RW: [user.username])

        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: Routes.my_project_path(conn, :show, %{"id" => project.id}))

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect changeset
        conn
        |> render("new.html",
          layout: {GithomeWeb.LayoutView, "main.html"},
          changeset: changeset,
          user: get_session(conn, :user),
          nav_active: get_session(conn, :nav_active)
        )
    end
  end

  def view(conn, %{"id" => id, "file" => file, "branch" => branch, "path" => path}) do
    %{project_name: name} = Projects.get_project!(id)
    code = Git.git_show(name, branch, Path.join(path, file))

    conn
    |> render("view.html",
      code: code,
      user: get_session(conn, :user),
      nav_active: get_session(conn, :nav_active)
    )
  end

  def log(conn, %{"id" => id, "item" => item, "branch" => branch}) do
    %{project_name: name} = Projects.get_project!(id)

    log =
      case item do
        [] -> Git.git_log(name, branch)
        "" -> Git.git_log(name, branch)
        items -> Git.git_log(name, branch, [items])
      end

    conn
    |> render("log.html",
      user: get_session(conn, :user),
      nav_active: get_session(conn, :nav_active),
      log: log
    )
  end

  def edit(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    changeset = Projects.change_project(project)

    conn
    |> render("edit.html",
      layout: {GithomeWeb.LayoutView, "main.html"},
      id: %{"id" => project.id},
      changeset: changeset,
      user: get_session(conn, :user),
      nav_active: get_session(conn, :nav_active)
    )
  end

  def update(conn, params) do
    IO.inspect(params)
    id = params["id"]

    id =
      case Integer.parse(id) do
        :error ->
          conn
          |> put_flash(:info, "Update fail.")
          |> Githome.redirect_back(default: "/")

        {id, _} ->
          id
      end

    project_params = params["project"]
    project = Projects.get_project!(id)

    case Projects.update_project(project, project_params) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: Routes.my_project_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", project: project, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    Git.delete_project(project.project_name)
    {:ok, _project} = Projects.delete_project(project)

    conn
    |> put_flash(:info, "Project deleted successfully.")
    |> redirect(to: Routes.my_project_path(conn, :index))
  end
end
