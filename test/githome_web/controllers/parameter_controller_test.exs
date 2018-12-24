defmodule GithomeWeb.ParameterControllerTest do
  use GithomeWeb.ConnCase

  alias Githome.Settrings

  @create_attrs %{key: "some key", value: "some value"}
  @update_attrs %{key: "some updated key", value: "some updated value"}
  @invalid_attrs %{key: nil, value: nil}

  def fixture(:parameter) do
    {:ok, parameter} = Settrings.create_parameter(@create_attrs)
    parameter
  end

  describe "index" do
    test "lists all settings", %{conn: conn} do
      conn = get(conn, Routes.parameter_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Settings"
    end
  end

  describe "new parameter" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.parameter_path(conn, :new))
      assert html_response(conn, 200) =~ "New Parameter"
    end
  end

  describe "create parameter" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.parameter_path(conn, :create), parameter: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.parameter_path(conn, :show, id)

      conn = get(conn, Routes.parameter_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Parameter"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.parameter_path(conn, :create), parameter: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Parameter"
    end
  end

  describe "edit parameter" do
    setup [:create_parameter]

    test "renders form for editing chosen parameter", %{conn: conn, parameter: parameter} do
      conn = get(conn, Routes.parameter_path(conn, :edit, parameter))
      assert html_response(conn, 200) =~ "Edit Parameter"
    end
  end

  describe "update parameter" do
    setup [:create_parameter]

    test "redirects when data is valid", %{conn: conn, parameter: parameter} do
      conn = put(conn, Routes.parameter_path(conn, :update, parameter), parameter: @update_attrs)
      assert redirected_to(conn) == Routes.parameter_path(conn, :show, parameter)

      conn = get(conn, Routes.parameter_path(conn, :show, parameter))
      assert html_response(conn, 200) =~ "some updated key"
    end

    test "renders errors when data is invalid", %{conn: conn, parameter: parameter} do
      conn = put(conn, Routes.parameter_path(conn, :update, parameter), parameter: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Parameter"
    end
  end

  describe "delete parameter" do
    setup [:create_parameter]

    test "deletes chosen parameter", %{conn: conn, parameter: parameter} do
      conn = delete(conn, Routes.parameter_path(conn, :delete, parameter))
      assert redirected_to(conn) == Routes.parameter_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.parameter_path(conn, :show, parameter))
      end
    end
  end

  defp create_parameter(_) do
    parameter = fixture(:parameter)
    {:ok, parameter: parameter}
  end
end
