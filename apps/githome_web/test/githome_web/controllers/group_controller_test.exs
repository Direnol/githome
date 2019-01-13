defmodule GithomeWeb.GroupControllerTest do
  use GithomeWeb.ConnCase

  alias Githome.Groups
  import GithomeWeb.Factory
  use PhoenixIntegration

  @create_attrs %{name: "some name", pid: 42, uid: 42}
  # @update_attrs %{name: "some updated name", pid: 43, uid: 43}

  def fixture(:group) do
    {:ok, group} = Groups.create_group(@create_attrs)
    group
  end

  describe "index" do
    setup do
      user = insert(:user)

      uconn =
        get(build_conn(), "/")
        |> follow_form(
          %{
            username: user.username,
            password: user.password,
            _csrf_token: "token"
          },
          identifier: "#login-form"
        )
        |> assert_response(path: "/my_projects")

      [uconn: uconn]
    end

    test "lists all groups", %{uconn: uconn} do
      uconn
      |> assert_response(path: "/my_projects")
      |> get(Routes.group_path(uconn, :index))
      |> assert_response(status: 200)
      |> assert_response(body: "All Groups")
    end
  end

  describe "new group" do
    setup do
      user = insert(:user)

      uconn =
        get(build_conn(), "/")
        |> follow_form(
          %{
            username: user.username,
            password: user.password,
            _csrf_token: "token"
          },
          identifier: "#login-form"
        )
        |> assert_response(path: "/my_projects")

      [uconn: uconn]
    end

    test "renders form", %{uconn: uconn} do
      uconn
      |> assert_response(path: "/my_projects")
      |> get(Routes.group_path(uconn, :new))
      |> assert_response(status: 200)
      |> assert_response(body: "New Group")
    end
  end

  describe "create group" do
    setup do
      user = insert(:user)

      uconn =
        get(build_conn(), "/")
        |> follow_form(
          %{
            username: user.username,
            password: user.password,
            _csrf_token: "token"
          },
          identifier: "#login-form"
        )
        |> assert_response(path: "/my_projects")

      [uconn: uconn]
    end

    test "redirects to show when data is valid", %{uconn: uconn} do
      projects =
        Enum.map(
          build_list(5, :project, owner: uconn.assigns.user.id),
          fn p ->
            uconn
            |> get(Routes.my_project_path(uconn, :new))
            |> assert_response(path: Routes.my_project_path(uconn, :new))
            |> follow_form(%{
              project: %{
                project_name: p.project_name,
                description: p.description
              }
            })
            |> assert_response(path: Routes.my_project_path(uconn, :show))
            |> Map.get(:assigns)
            |> Map.get(:project)
            |> Map.get(:id)
          end
        )

      members = Enum.map(insert_list(5, :user), fn u -> u.id end)

      uconn
      |> get(Routes.my_group_path(uconn, :new))
      |> assert_response(status: 200)
      |> assert_response(body: "New Group")
      |> follow_form(%{
        ginfo: %{
          name: "name",
          description: "desc",
          projects: projects,
          members: members
        }
      })
      |> assert_response(path: Routes.my_group_path(uconn, :show))
      |> assert_response(
        value: fn conn ->
          Enum.each(
            projects,
            &assert_response(conn, body: Routes.my_project_path(conn, :show, %{"id" => &1}))
          )

          Enum.each(
            Githome.Members.get_all_members_by_group(conn.params["id"]),
            &assert_response(conn, body: &1.username)
          )
        end
      )
    end

    test "renders errors when data is invalid", %{uconn: uconn} do
      uconn
      |> get(Routes.my_group_path(uconn, :new))
      |> assert_response(status: 200)
      |> assert_response(body: "New Group")
      |> follow_form(%{
        ginfo: %{
          name: nil,
          description: nil,
          projects: nil,
          members: nil
        }
      })
      |> assert_response(path: Routes.my_group_path(uconn, :new))
    end
  end

  #
  #  describe "edit group" do
  #    setup [:create_group]
  #
  #    test "renders form for editing chosen group", %{conn: conn, group: group} do
  #      conn = get(conn, Routes.group_path(conn, :edit, group))
  #      assert html_response(conn, 200) =~ "Edit Group"
  #    end
  #  end
  #
  #  describe "update group" do
  #    setup [:create_group]
  #
  #    test "redirects when data is valid", %{conn: conn, group: group} do
  #      conn = put(conn, Routes.group_path(conn, :update, group), group: @update_attrs)
  #      assert redirected_to(conn) == Routes.group_path(conn, :show, group)
  #
  #      conn = get(conn, Routes.group_path(conn, :show, group))
  #      assert html_response(conn, 200) =~ "some updated name"
  #    end
  #
  #    test "renders errors when data is invalid", %{conn: conn, group: group} do
  #      conn = put(conn, Routes.group_path(conn, :update, group), group: @invalid_attrs)
  #      assert html_response(conn, 200) =~ "Edit Group"
  #    end
  #  end
  #
  #  describe "delete group" do
  #    setup [:create_group]
  #
  #    test "deletes chosen group", %{conn: conn, group: group} do
  #      conn = delete(conn, Routes.group_path(conn, :delete, group))
  #      assert redirected_to(conn) == Routes.group_path(conn, :index)
  #
  #      assert_error_sent 404, fn ->
  #        get(conn, Routes.group_path(conn, :show, group))
  #      end
  #    end
  #  end
  #
  #  defp create_group(_) do
  #    group = fixture(:group)
  #    {:ok, group: group}
  #  end
end
