defmodule GithomeWeb.ProjectControllerTest do
  use GithomeWeb.ConnCase

  alias Githome.Projects
  import GithomeWeb.Factory
  use PhoenixIntegration, expect: [:delete]

  @project %{project: %{project_name: "test_project", description: "test desc"}}

  describe "My projects" do
    setup do
      user = insert(:user)

      uconn =
        get(build_conn(), "/")
        |> follow_form(%{username: user.username, password: user.password},
          identifier: "#login-form"
        )
        |> assert_response(path: "/my_projects")

      admin = insert(:user, admin: true)

      aconn =
        get(build_conn(), "/")
        |> follow_form(%{username: admin.username, password: admin.password},
          identifier: "#login-form"
        )
        |> assert_response(path: "/my_projects")

      [uconn: uconn, aconn: aconn]
    end

    test "create", %{uconn: conn} do
      conn
      |> follow_link("Add")
      |> assert_response(path: Routes.my_project_path(conn, :new))
      |> follow_form(@project)
      |> assert_response(path: Routes.my_project_path(conn, :show))
    end

    test "delete", %{uconn: conn} do
      proj = insert(:project)

      conn
      |> delete(Routes.my_project_path(conn, :delete, %{"id" => proj.id}))

      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(proj.id) end
    end

    test "list", %{uconn: conn} do
      ps = insert_list(5, :project, owner: conn.assigns.user.id)

      conn
      |> get(Routes.my_project_path(conn, :index))
      |> assert_response(
        value: fn conn ->
          Enum.each(ps, &assert_response(conn, body: &1.project_name))
        end
      )
    end
  end
end
