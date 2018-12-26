defmodule Githome.GroupProject do
  alias Githome.GroupProject.Gp
  alias Githome.Projects.Project
  alias Githome.Repo
  import Ecto.Query, warn: false

  def list_gps do
    Repo.all(Gp)
  end

  def get_gp!(id), do: Repo.get!(Gp, id)
  def get_gp_by!(search), do: Repo.get_by!(Gp, search)
  def get_gp_by(search), do: Repo.get_by(Gp, search)

  def create_gp(attrs \\ %{}) do
    %Gp{}
    |> Gp.changeset(attrs)
    |> Repo.insert()
  end

  def update_gp(%Gp{} = group, attrs) do
    group
    |> Gp.changeset(attrs)
    |> Repo.update()
  end

  def delete_gp(%Gp{} = group) do
    Repo.delete(group)
  end

  def change_gp(%Gp{} = group) do
    Gp.changeset(group, %{})
  end

  def get_all_project_by_group(id) do
    query = from pr in Project,
           right_join: gr in Gp,
           on: pr.id == gr.pid,
           select: pr,
           where: gr.gid == ^id
    query
    |> Ecto.Queryable.to_query()
    |> Repo.all()
  end
end