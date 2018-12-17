defmodule GithomeWeb.LoginController do
  use GithomeWeb, :controller

  alias Githome.Users
  alias Githome.Users.User

  def index(conn, _params) do
    render(conn, "index.html", token: get_csrf_token(), info: get_flash(conn, :info))
  end

  def login(conn, param) do
    login = param["username"]
    pass = param["password"]
    case login == pass do
      true -> conn |> redirect(to: Routes.session_path(conn, :new))
      _ -> conn
           |> put_flash(:info, "User deleted successfully.")
           |> redirect(to: Routes.login_path(conn, :index))
    end
  end

  def register(conn, param) do
    IO.inspect(param)
    login = param["username"]
    pass = param["password"]
    confirm_pass =param["confirm-password"]
    case pass == confirm_pass do
      true -> conn
              |> create(%{"user" => %{:username => login, :password => pass, :password_confirmation => confirm_pass}})
      _ -> conn
           |> put_flash(:info, "Check your password")
           |> redirect(to: Routes.login_path(conn, :index))
    end
  end

  def create(conn, %{"user" => user_params}) do
    case Users.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:info, "Check your parameters")
        |> redirect(to: Routes.login_path(conn, :index))
    end
  end
end
