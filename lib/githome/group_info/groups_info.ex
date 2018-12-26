defmodule Githome.GroupInfo do
  alias Githome.GroupInfo.Group
  alias Githome.Repo

  def get_group(id) do
    Repo.get Group, id
  end

  def get_group!(id) do
    Repo.get! Group, id
  end

  def get_group_by(field) do
    Repo.get_by Group, field
  end

  def get_group_by!(field) do
    Repo.get_by! Group, field
  end
end
