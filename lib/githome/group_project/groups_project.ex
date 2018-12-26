defmodule Githome.GroupProject do
  alias Githome.GroupProject.Gp
  alias Githome.Repo

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

end