defmodule GithomeWeb.ParameterController do
  use GithomeWeb, :controller

  alias Githome.Settrings
  alias Githome.Settrings.Parameter

  def index(conn, _params) do
    token = get_session(conn, :token)
    case token  do
      nil ->
        conn
        |> put_flash(:info, "Please sign in")
        |> redirect(to: Routes.login_path(conn, :index))
      _ ->
        user = get_session(conn, :user)
        case is_map(user) do
          true ->
            user_update = Users.get_user!(user.id)
            settings = Settrings.list_settings()
            conn
              |> put_session(:user, user_update)
              |> put_session(:nav_active, :settings)
              |> render("index.html", settings: settings, layout: {GithomeWeb.LayoutView, "main.html"}, user: get_session(conn, :user), nav_active: get_session(conn, :nav_active))
          _ ->
            conn
            |> put_flash(:info, "Please sign in")
            |> redirect(to: Routes.login_path(conn, :index))
        end
    end
  end

  def new(conn, _params) do
    token = get_session(conn, :token)
    case token  do
      nil ->
        conn
        |> put_flash(:info, "Please sign in")
        |> redirect(to: Routes.login_path(conn, :index))
      _ ->
        user = get_session(conn, :user)
        if user == nil do
          conn
          |> put_flash(:info, "Please sign in")
          |> redirect(to: Routes.login_path(conn, :index))
        end
        changeset = Settrings.change_parameter(%Parameter{})
        conn = put_session(conn, :nav_active, :settings)
        render(conn, "new.html", changeset: changeset, layout: {GithomeWeb.LayoutView, "main.html"}, user: get_session(conn, :user), nav_active: get_session(conn, :nav_active))
    end
    changeset = Settrings.change_parameter(%Parameter{})
    render(conn, "new.html", changeset: changeset, layout: {GithomeWeb.LayoutView, "main.html"}, user: get_session(conn, :user), nav_active: get_session(conn, :nav_active))
  end

  def create(conn, %{"parameter" => parameter_params}) do
    case Settrings.create_parameter(parameter_params) do
      {:ok, parameter} ->
        conn
        |> put_flash(:info, "Parameter created successfully.")
        |> redirect(to: Routes.parameter_path(conn, :show, parameter))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    parameter = Settrings.get_parameter!(id)
    render(conn, "show.html", parameter: parameter)
  end

  def edit(conn, %{"id" => id}) do
    parameter = Settrings.get_parameter!(id)
    changeset = Settrings.change_parameter(parameter)
    render(conn, "edit.html", parameter: parameter, changeset: changeset)
  end

  def update(conn, %{"id" => id, "parameter" => parameter_params}) do
    parameter = Settrings.get_parameter!(id)

    case Settrings.update_parameter(parameter, parameter_params) do
      {:ok, parameter} ->
        conn
        |> put_flash(:info, "Parameter updated successfully.")
        |> redirect(to: Routes.parameter_path(conn, :show, parameter))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", parameter: parameter, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    parameter = Settrings.get_parameter!(id)
    {:ok, _parameter} = Settrings.delete_parameter(parameter)

    conn
    |> put_flash(:info, "Parameter deleted successfully.")
    |> redirect(to: Routes.parameter_path(conn, :index))
  end
end
