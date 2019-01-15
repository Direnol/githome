defmodule GithomeWeb.LoginController do
  use GithomeWeb, :controller
  alias Githome.Users
  import Comeonin.Bcrypt, only: [checkpw: 2]
  alias GithomeWeb.CheckAuth

  plug GithomeWeb.CheckAuth, :auth when action in [:login, :register]
  plug GithomeWeb.CheckAuth, :auth? when action in [:index]

  def index(conn, _params) do
    render(conn, "index.html", token: get_csrf_token(), info: get_flash(conn, :info))
  end

  def login(conn, param) do
    user = Users.get_user_by(username: param["username"])

    case if(user,
           do: checkpw(param["password"], Map.get(user, :password_digest)),
           else: false
         ) do
      true ->
        update_tok = %{CheckAuth.get_info(conn) | id: user.id} |> CheckAuth.auth()

        conn
        |> put_session(:auth_token, update_tok)
        |> redirect(
          to:
            Routes.session_path(conn, :new,
              username: param["username"],
              token: param["_csrf_token"]
            )
        )

      _ ->
        conn
        |> fetch_session
        |> clear_session
        |> put_flash(:info, "Incorrected password or username.")
        |> redirect(to: Routes.login_path(conn, :index))
    end
  end

  def register(conn, param) do
    login = param["username"]
    pass = param["password"]
    confirm_pass = param["confirm"]
    token = param["_csrf_token"]

    case Users.get_user_by(username: login) do
      nil ->
        case pass == confirm_pass do
          true ->
            conn
            |> create(%{
              :username => login,
              :password => pass,
              :password_confirm => confirm_pass
            })
            |> redirect(to: Routes.session_path(conn, :new, username: login, token: token))

          _ ->
            conn
            |> put_flash(:info, "Check your password")
            |> redirect(to: Routes.login_path(conn, :index))
        end

      _ ->
        conn
        |> fetch_session
        |> clear_session
        |> put_flash(:info, "Already exist")
        |> redirect(to: Routes.login_path(conn, :index))
    end
  end

  defp create(conn, user_params) do
    case Users.create_user(user_params) do
      {:ok, user} ->
        update_tok = %{CheckAuth.get_info(conn) | id: user.id} |> CheckAuth.auth()

        conn
        |> put_session(:auth_token, update_tok)
        |> put_flash(:info, "User created successfully")

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:info, "Check your parameters")
        |> redirect(to: Routes.login_path(conn, :index))
    end
  end
end
