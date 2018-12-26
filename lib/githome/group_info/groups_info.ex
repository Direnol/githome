defmodule Githome.GroupInfo do
  alias Githome.GroupInfo.Ginfo
  alias Githome.Repo

  def list_ginfos do
    Repo.all(Ginfo)
  end

  def get_ginfo!(id), do: Repo.get!(Ginfo, id)
  def get_ginfo_by!(search), do: Repo.get_by!(Ginfo, search)
  def get_ginfo_by(search), do: Repo.get_by(Ginfo, search)

  def create_ginfo(attrs \\ %{}) do
    %Ginfo{}
    |> Ginfo.changeset(attrs)
    |> Repo.insert()
  end

  def update_ginfo(%Ginfo{} = group, attrs) do
    group
    |> Ginfo.changeset(attrs)
    |> Repo.update()
  end

  def delete_ginfo(%Ginfo{} = group) do
    Repo.delete(group)
  end

  def change_ginfo(%Ginfo{} = group) do
    Ginfo.changeset(group, %{})
  end
end
