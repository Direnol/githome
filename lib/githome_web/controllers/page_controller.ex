defmodule GithomeWeb.PageController do
  use GithomeWeb, :controller

  plug :put_layout, "main.html"

  def index(conn, _params) do
    token = get_session(conn, :token)
    case token  do
      nil ->
          conn
            |> put_flash(:info, "Please sign in")
            |> redirect(to: Routes.login_path(conn, :index))
      _ ->
          render(conn, "index.html", layout: {GithomeWeb.LayoutView, "main.html"})
    end
  end
end
