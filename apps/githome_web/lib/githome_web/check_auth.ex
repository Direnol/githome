defmodule GithomeWeb.CheckAuth do
  import Plug.Conn
  import Phoenix.Controller
  alias GithomeWeb.Router.Helpers, as: Routes
  alias Phoenix.Token
  alias Githome.Users
  alias __MODULE__
  require Logger

  defstruct username: nil, id: nil, remember: false

  @type t :: %__MODULE__{
          username: String.t(),
          id: Integer.t(),
          remember: true | false
        }

  @behaviour Plug

  @sault Application.get_env(:githome_web, :token_sault)
  @verify_opts [max_age: Application.get_env(:githome_web, :token_live)]

  @spec init(atom()) :: atom()
  def init(param), do: param

  @spec auth(CheckAuth.t()) :: String.t()
  def auth(%CheckAuth{} = info) do
    Token.sign(GithomeWeb.Endpoint, @sault, info)
  end

  @spec auth(Plug.Conn.t(), CheckAuth.t()) :: Plug.Conn.t()
  defp auth(conn, info) do
    Logger.info("Auth #{inspect(info)}")

    conn
    |> put_session(:auth_token, auth(info))
  end

  @spec verify(Plug.Conn.t(), String.t(), Keyword.t() | []) :: Plug.Conn.t()
  def verify(conn, tok, opts \\ []) do
    case Token.verify(GithomeWeb.Endpoint, @sault, tok, Keyword.merge(@verify_opts, opts)) do
      {:error, reason} ->
        conn
        |> bad_auth_token("Token is #{reason}")
        |> redirect(to: Routes.login_path(conn, :index))
        |> halt

      {:ok, info} ->
        case Users.get_user_by(username: info.username, id: info.id || -1) do
          nil ->
            conn
            |> bad_auth_token("Token Owned by non-existent user: #{inspect(info)}")
            |> redirect(to: Routes.login_path(conn, :index))
            |> halt

          _ ->
            auth(conn, info)
        end
    end
  end

  @spec get_info(Plug.Conn.t()) :: __MODULE__.t() | nil
  def get_info(conn) do

     case Token.verify(GithomeWeb.Endpoint, @sault, get_session(conn, :auth_token), @verify_opts) do
      {:ok, info} -> info
      _ -> nil
     end
  end

  @spec bad_auth_token(Plug.Conn.t, String.t) :: Plug.Conn.t
  defp bad_auth_token(conn, message) do
    Logger.warn("#{message}")

    conn
    |> fetch_session
    |> clear_session
  end

  @spec call(Plug.Conn.t, :auth) :: Plug.Conn.t
  def call(conn, :auth) do
    conn
    |> auth(%CheckAuth{
      username: conn.params["username"]
    })
  end

  @spec call(Plug.Conn.t, :auth?) :: Plug.Conn.t
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

  @spec call(Plug.Conn.t, :verify) :: Plug.Conn.t
  def call(conn, :verify) do
    case get_session(conn, :auth_token) do
      nil ->
        conn
        |> bad_auth_token("Token is not founded")
        |> put_flash(:info, "Please sign in")
        |> redirect(to: Routes.login_path(conn, :index))
        |> halt
      tok ->
        verify(conn, tok)
    end
  end
end
