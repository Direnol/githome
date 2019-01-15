defmodule GithomeWeb.ParameterController do
  use GithomeWeb, :controller

  alias Githome.Settings
  alias Githome.Settings.Parameter
  alias Githome.Users

  def index(conn, _params) do
    user = get_session(conn, :user)

    case is_map(user) do
      true ->
        user_update = Users.get_user!(user.id)

        case user_update.admin do
          true ->
            settings = Settings.list_settings()

            conn
            |> put_session(:user, user_update)
            |> put_session(:nav_active, :settings)
            |> render("index.html",
              settings: settings,
              layout: {GithomeWeb.LayoutView, "main.html"},
              user: user_update,
              nav_active: :settings
            )

          _ ->
            conn
            |> put_flash(:info, "Access deny.")
            |> redirect(to: Routes.login_path(conn, :index))
        end
    end
  end

  def new(conn, _params) do
    user = get_session(conn, :user)

    changeset = Settings.change_parameter(%Parameter{})
    conn = put_session(conn, :nav_active, :settings)

    render(conn, "new.html",
      changeset: changeset,
      layout: {GithomeWeb.LayoutView, "main.html"},
      user: get_session(conn, :user),
      nav_active: get_session(conn, :nav_active)
    )

    changeset = Settings.change_parameter(%Parameter{})

    render(conn, "new.html",
      changeset: changeset,
      layout: {GithomeWeb.LayoutView, "main.html"},
      user: get_session(conn, :user),
      nav_active: get_session(conn, :nav_active)
    )
  end

  def create(conn, %{"parameter" => parameter_params}) do
    case Settings.create_parameter(parameter_params) do
      {:ok, parameter} ->
        conn
        |> put_flash(:info, "Parameter created successfully.")
        |> redirect(to: Routes.parameter_path(conn, :show, parameter))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    parameter = Settings.get_parameter!(id)
    render(conn, "show.html", parameter: parameter)
  end

  def edit(conn, %{"id" => id}) do
    parameter = Settings.get_parameter!(id)
    changeset = Settings.change_parameter(parameter)
    render(conn, "edit.html", parameter: parameter, changeset: changeset)
  end

  def update(conn, %{"id" => id, "parameter" => parameter_params}) do
    parameter = Settings.get_parameter!(id)

    case Settings.update_parameter(parameter, parameter_params) do
      {:ok, parameter} ->
        conn
        |> put_flash(:info, "Parameter updated successfully.")
        |> redirect(to: Routes.parameter_path(conn, :show, parameter))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", parameter: parameter, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    parameter = Settings.get_parameter!(id)
    {:ok, _parameter} = Settings.delete_parameter(parameter)

    conn
    |> put_flash(:info, "Parameter deleted successfully.")
    |> redirect(to: Routes.parameter_path(conn, :index))
  end
end
