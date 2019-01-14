defmodule GithomeWeb.CheckAuth do
  import Plug.Conn
  import Phoenix.Controller
  alias GithomeWeb.Router.Helpers, as: Routes
  alias Phoenix.Token
  alias __MODULE__
  require Logger

  defstruct username: ""

  @behaviour Plug

  @sault Application.get_env(:githome_web, :token_sault)
  @verify_opts [max_age: Application.get_env(:githome_web, :token_live)]
  def init(param), do: param

  defp auth(conn, info) do
    tok = Token.sign(GithomeWeb.Endpoint, @sault, info)

    conn
    |> put_session(:auth_token, tok)
  end

  def verify(conn, tok, opts \\ []) do
    case Token.verify(GithomeWeb.Endpoint, @sault, tok, Keyword.merge(@verify_opts, opts)) do
      {:error, reason} ->
        conn
        |> bad_auth_token("Token is #{reason}")
        |> redirect(to: Routes.login_path(conn, :index))
        |> halt

      {:ok, info} ->
        auth(conn, info)
    end
  end

  def get_info(conn) do
    {:ok, info} =
      Token.verify(GithomeWeb.Endpoint, @sault, get_session(conn, :auth_token), @verify_opts)

    info
  end

  defp bad_auth_token(conn, message) do
    Logger.info("#{message}")

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
