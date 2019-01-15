defmodule GithomeWeb.CheckAuth do
  import Plug.Conn
  import Phoenix.Controller
  alias GithomeWeb.Router.Helpers, as: Routes
  alias Phoenix.Token
  alias Githome.Users
  alias __MODULE__
  require Logger

  defstruct username: nil, id: nil, remember: false

  @type t() :: %__MODULE__{
          username: String.t(),
          id: Integer.t(),
          remember: true | false
        }

  @behaviour Plug

  @sault Application.get_env(:githome_web, :token_sault)
  @verify_opts [max_age: Application.get_env(:githome_web, :token_live)]
  def init(param), do: param

  def auth(%CheckAuth{} =  info) do
    Token.sign(GithomeWeb.Endpoint, @sault, info)
  end
  defp auth(conn, info) do
    Logger.info("Auth #{inspect(info)}")

    conn
    |> put_session(:auth_token, auth(info))
  end

  def verify(conn, tok, opts \\ []) do
    case Token.verify(GithomeWeb.Endpoint, @sault, tok, Keyword.merge(@verify_opts, opts)) do
      {:error, reason} ->
        conn
        |> bad_auth_token("Token is #{reason}")
        |> redirect(to: Routes.login_path(conn, :index))
        |> halt

      {:ok, info} ->
        case Users.get_user_by(username: info.username, id: (info.id || -1)) do
          nil ->
            conn
            |> bad_auth_token("Token Owned by non-existent user: #{inspect info}")
            |> redirect(to: Routes.login_path(conn, :index))
            |> halt

          _ ->
            auth(conn, info)
        end
    end
  end

  def get_info(conn) do
    {:ok, info} =
      Token.verify(GithomeWeb.Endpoint, @sault, get_session(conn, :auth_token), @verify_opts)

    info
  end

  defp bad_auth_token(conn, message) do
    Logger.warn("#{message}")

    conn
    |> fetch_session
    |> clear_session
    |> put_session(:info, message)
  end

  def call(conn, :auth) do
    conn
    |> auth(%CheckAuth{
      username: conn.params["username"]
    })
  end

  def call(conn, :auth?) do
    case get_session(conn, :auth_token) do
      nil ->
        conn

      tok ->
        case verify(conn, tok) do
          %{halted: true} ->
            conn

          aconn ->
            aconn
            |> redirect(
              to:
                Routes.session_path(aconn, :new,
                  username: get_info(aconn).username,
                  token: get_csrf_token()
                )
            )
            |> halt
        end
    end
  end

  def call(conn, :verify) do
    case get_session(conn, :auth_token) do
      nil ->
        conn
        |> bad_auth_token("Token is not founded")
        |> redirect(to: Routes.login_path(conn, :index))
        |> halt

      tok ->
        verify(conn, tok)
    end
  end
end
