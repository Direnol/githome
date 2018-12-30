defmodule Githome.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias Githome.Repo

  alias Githome.Projects.Project
  alias Githome.GroupProject.Gp
  alias Githome.GroupInfo.Ginfo
  alias Githome.Groups
  alias Githome.GroupProject

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  def list_my_projects(id) do
    query = from p in Project, select: p, where: p.owner == ^id

    # May be User or an Ecto.Query itself
    query
    |> Ecto.Queryable.to_query()
    |> Repo.all()
  end

  def get_all_my_projects(id) do
    projects =
      for g <- Groups.list_my_groups(id) do
        GroupProject.get_all_project_by_group(g.id)
      end
      |> List.flatten()

    projects ++ list_my_projects(id)
  end

  def get_groups_by_project(id) do
    query =
      from i in Ginfo,
        right_join: gp in Gp,
        on: i.id == gp.gid,
        select: i,
        where: gp.pid == ^id

    query
    |> Ecto.Queryable.to_query()
    |> Repo.all()
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)
  def get_project_by!(search), do: Repo.get_by!(Project, search)
  def get_project_by(search), do: Repo.get_by(Project, search)

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    from(pg in Gp, where: pg.pid == ^project.id) |> Repo.delete_all()
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{source: %Project{}}

  """
  def change_project(%Project{} = project) do
    Project.changeset(project, %{})
  end
end
