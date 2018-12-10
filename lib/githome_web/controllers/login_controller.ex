defmodule GithomeWeb.LoginController do
  use GithomeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
