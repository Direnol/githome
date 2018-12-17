defmodule GithomeWeb.SessionController do
  use GithomeWeb, :controller

  alias Githome.Users
  alias Githome.Users.User

  def new(conn, _params) do
    render(conn, "new.html")
  end
end