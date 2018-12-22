defmodule GithomeWeb.LoginController do
  use GithomeWeb, :controller

  alias Githome.Users
  alias Githome.Users.User
  import Comeonin.Bcrypt, only: [checkpw: 2]

  def index(conn, _params) do
    render(conn, "index.html", token: get_csrf_token(), info: get_flash(conn, :info))
  end

  def login(conn, param) do
    IO.inspect(param)

    db_hash =
      case Users.get_user_by(username: param["username"]) do
        nil -> nil
        db_user -> Map.get(db_user, :password_digest)
      end

    ret =
      if db_hash do
        checkpw(param["password"], db_hash)
      end

    case ret do
      true ->
        conn |> redirect(to: Routes.session_path(conn, :new, username: param["username"], token: param["_csrf_token"]))

      _ ->
        conn
        |> put_flash(:info, "Incorrected password or username.")
        |> redirect(to: Routes.login_path(conn, :index))
    end
  end

  def register(conn, param) do
    login = param["username"]
    pass = param["password"]
    confirm_pass = param["confirm-password"]
    token = param["_csrf_token"]

    case Users.get_user_by(username: login) do
      nil ->
        case pass == confirm_pass do
          true ->
            conn
            |> create(%{
              "user" => %{
                :username => login,
                :password => pass,
                :password_confirm => confirm_pass
              },
              "token" => token
            })

          _ ->
            conn
            |> put_flash(:info, "Check your password")
            |> redirect(to: Routes.login_path(conn, :index))
        end

      _ ->
        conn
            |> put_flash(:info, "Already exist")
            |> redirect(to: Routes.login_path(conn, :index))
    end
  end

  def customize(conn, _) do
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
        conn
          |> put_layout({LayoutView, "reg.html"})
          |> redirect(to: Routes.user_path(conn, :edit))
    end
  end

  defp create(conn, %{"user" => user_params, "token" => token}) do
    case Users.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully")
        |> register_session(%{username: user_params[:username], token: token})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:info, "Check your parameters")
        |> redirect(to: Routes.login_path(conn, :index))
    end
  end

  defp register_session(conn, params) do
    token = params[:token]
    username = params[:username]
    IO.inspect(token)
    case String.valid?(token) do
      true ->
        conn
          |> put_session(:token, token)
          |> put_session(:user, Users.get_user_by(username: username))
          |> redirect(to: Routes.login_path(conn, :customize))
      _ ->
        conn
          |> redirect(to: Routes.login_path(conn, :index))
    end
  end
end
