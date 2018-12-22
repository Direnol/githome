defmodule GithomeWeb.UserController do
  use GithomeWeb, :controller

  alias Githome.Users
  alias Githome.Users.User
  import Comeonin.Bcrypt, only: [checkpw: 2]

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
        if user == nil do
          conn
          |> put_flash(:info, "Please sign in")
          |> redirect(to: Routes.login_path(conn, :index))
        end
        users = Users.list_users()
        conn = put_session(conn, :nav_active, :users)
        conn
        |> render("index.html", users: users, layout: {GithomeWeb.LayoutView, "main.html"}, user: get_session(conn, :user), nav_active: get_session(conn, :nav_active))
    end
  end

  def new(conn, _params) do
    token = get_session(conn, :token)
    case token  do
      nil ->
        conn
        |> put_flash(:info, "Please sign in")
        |> redirect(to: Routes.login_path(conn, :index))
      _ ->
        changeset = Users.change_user(%User{})
        IO.inspect(changeset)
        conn
        |> render("new.html", changeset: changeset, user: get_session(conn, :user), nav_active: get_session(conn, :nav_active), token: get_session(conn, :token))
    end
  end

  def create(conn, %{"user" => user_params}) do
    case Users.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:info, "Check your parameters")
        |> redirect(to: Routes.login_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, _) do
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
        changeset = Users.changeset_customize_user(user)
        IO.inspect(changeset)
        conn
          |> render("edit.html", user: user, changeset: changeset, nav_active: get_session(conn, :nav_active), token: get_session(conn, :token))
    end
  end

  def update(conn, params) do
    if params["_csrf_token"] != get_session(conn, :token) do
      conn
      |> put_flash(:info, "Failed to register user. Please try again")
      |> redirect(to: Routes.login_path(conn, :index))
    end
    case get_session(conn, :user) do
      nil ->
        conn
        |> put_flash(:info, "Failed to register user. Please try again")
        |> redirect(to: Routes.login_path(conn, :index))

      _ ->
        conn
        |> update_user_info(params)
    end
  end

  defp update_user_info(conn, user_params) do
    IO.inspect(user_params)
    user = get_session(conn, :user)
    avatar_uri = ""
    if upload = user_params["photo"] do
      IO.inspect(upload)
      extension = Path.extname(upload["filename"])
      File.cp(upload["path"], "/images/#{user.id}-avatar#{extension}")
      avatar_uri = "/images/#{user.id}-avatar#{extension}"
    end

    user_changeset = user_params["user"]
    Map.delete(user_changeset, "photo")
    Map.put(user_changeset, "avatar_uri", avatar_uri)
    IO.inspect(user_changeset)


    case Users.update_user(user, user_changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:info, "Sorry try again")
        |> Githome.redirect_back(default: "/")
    end
  end

  def update_password(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    case Users.update_user_pass(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:info, "Sorry try again")
        |> Githome.redirect_back(default: "/")
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    {:ok, _user} = Users.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end

  def change_password(conn, params) do
    conn = put_session(conn, :nav_active, :user_change_pass)
    render(conn, "change_password.html", layout: {GithomeWeb.LayoutView, "main.html"}, token: get_session(conn, :token), user: get_session(conn, :user), nav_active: get_session(conn, :nav_active), info: get_flash(conn, :info))
  end

  defp change_pwd(conn, %{"user" => user, "new_pass" => pass_confirm}) do
    update_password(conn, %{"id" => user.id,
                   "user" => %{:password => pass_confirm}
    })
  end

  def change_password_post(conn, params) do
      user = get_session(conn, :user)
      current_pass = params["current_password"]
      pass = params["password"]
      pass_confirm = params["password_confirmation"]

      case checkpw(current_pass, user.password_digest) do
        true ->
          case pass == pass_confirm do
            true ->
              conn
              |> change_pwd(%{"user" => user, "new_pass" => pass_confirm})
              |> put_flash(:info, "Please sign in")
              |> redirect(to: Routes.login_path(conn, :index))
            _ ->
              conn
              |> put_flash(:info, "Check your new password and try again")
              |> redirect(to: Routes.user_path(conn, :change_password))
          end
        _ ->
          conn
          |> put_flash(:info, "Check your current password and try again")
          |> redirect(to: Routes.user_path(conn, :change_password))
      end
  end
end