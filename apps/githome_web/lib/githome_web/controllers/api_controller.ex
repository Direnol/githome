defmodule GithomeWeb.ApiController do
  use GithomeWeb, :controller

  alias Githome.Users
  alias Githome.Projects

  @template "render.json"
  @available_api [
    "users",
    "projects"
  ]
  def index(conn, _) do
    conn
    |> render("index.json", %{api: @available_api})
  end

  def show(conn, %{"id" => db}) do
    conn
    |> render(@template, get_data(db))
  end

  defp get_data(name) do
    case name do
      "users" -> [users: Users.list_users()]
      "projects" -> [projects: Projects.list_projects()]
      _ -> [error: true]
    end
  end
end
