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
        case is_map(user) do
          true ->
            users = Users.list_users()
            user_update = Users.get_user!(user.id)
            conn
             |> put_session(:user, user_update)
             |> put_session(:nav_active, :users)
             |> render("index.html", users: users, layout: {GithomeWeb.LayoutView, "main.html"}, user: user_update, nav_active: :users)
          _ ->
            conn
            |> put_flash(:info, "Please sign in")
            |> redirect(to: Routes.login_path(conn, :index))
        end
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

  def show(conn, _) do
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
            conn
            |> put_session(:user, user_update)
            |> put_session(:nav_active, :user_my_profile)
            |> render("show.html", layout: {GithomeWeb.LayoutView, "main.html"}, user: user_update, nav_active: :user_my_profile)
          _ ->
            conn
            |> put_flash(:info, "Please sign in")
            |> redirect(to: Routes.login_path(conn, :index))
        end
      end
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
        |> update_user_info(params["user"])
    end
  end

  defp update_user_info(conn, user_params) do
    upload = Map.get(user_params, "photo")
    case is_map(upload) do
      true ->
        user = get_session(conn, :user)
        extension = Path.extname(Map.get(upload, :filename))
        avatar_path = "./priv/static/images/#{user.id}-avatar#{extension}"
        File.cp(Map.get(upload, :path), avatar_path)
        changeset = %{
          :avatar_uri => "/images/#{user.id}-avatar#{extension}",
          :email => user_params["email"],
          :first_name => user_params["first_name"],
          :last_name => user_params["last_name"],
          :ssh_key => user_params["ssh_key"]
        }
        case Users.update_user_info(user, changeset) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "User updated successfully")
            |> Githome.redirect_back(default: "/")

          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_flash(:info, "Sorry try again")
            |> Githome.redirect_back(default: "/")
        end

        _ ->
          user = get_session(conn, :user)
          changeset = %{
            :email => user_params["email"],
            :first_name => user_params["first_name"],
            :last_name => user_params["last_name"],
            :ssh_key => user_params["ssh_key"]
          }
          case Users.update_user_info(user, changeset) do
            {:ok, user} ->
              conn
              |> put_flash(:info, "User updated successfully")

            {:error, %Ecto.Changeset{} = changeset} ->
              conn
              |> put_flash(:info, "Sorry try again")
              |> Githome.redirect_back(default: "/")
          end
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