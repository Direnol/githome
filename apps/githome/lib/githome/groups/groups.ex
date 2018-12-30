defmodule Githome.Groups do
  @moduledoc """
  The Groups context.
  """

  import Ecto.Query, warn: false
  alias Githome.Repo

  alias Githome.Groups.Group
  alias Githome.GroupInfo.Ginfo
  alias Githome.GroupInfo
  alias Githome.GroupProject.Gp
  alias Githome.GroupProject
  alias Githome.Users.User

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups do
    Repo.all(Group)
  end

  def list_my_groups(id) do
    query =
      from i in Ginfo,
        left_join: g in Group,
        on: i.id == g.gid,
        select: i,
        where: g.uid == ^id

    query
    |> Ecto.Queryable.to_query()
    |> Repo.all()
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id), do: Repo.get!(Group, id)
  def get_group_by!(search), do: Repo.get_by!(Group, search)
  def get_group_by(search), do: Repo.get_by(Group, search)

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs \\ %{}) do
    name = attrs["name"]
    members = attrs["members"] || []
    projects = attrs["projects"] || []
    desc = attrs["description"] || "desc default"
    owner = attrs["owner"]

    case GroupInfo.create_ginfo(%{"name" => name, "description" => desc}) do
      {:ok, info} ->
        case insert_in_group(%{"gid" => info.id, "uid" => owner, "owner" => true}) do
          {:ok, _group} ->
            for member <- members, member != owner do
              insert_in_group(%{"gid" => info.id, "uid" => member, "owner" => false})
            end

            for project <- projects do
              GroupProject.create_gp(%{"pid" => project, "gid" => info.id})
            end

            {:ok, info}

          err ->
            err
        end

      err ->
        err
    end
  end

  def insert_in_group(attrs \\ %{}) do
    IO.inspect(attrs)

    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(id) do
    from(i in Ginfo, where: i.id == ^id) |> Repo.delete_all()
    from(g in Group, where: g.gid == ^id) |> Repo.delete_all()
    from(pg in Gp, where: pg.gid == ^id) |> Repo.delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{source: %Group{}}

  """
  def change_group(%Group{} = group) do
    Group.changeset(group, %{})
  end

  def get_all_members_by_group(id) do
    query =
      from u in User,
        right_join: gr in Group,
        on: u.id == gr.uid,
        select: u,
        where: gr.gid == ^id

    query
    |> Ecto.Queryable.to_query()
    |> Repo.all()
  end

  def get_owner_by_group(id) do
    query =
      from g in Group,
        select: g,
        where: g.gid == ^id and g.owner == true

    query
    |> Ecto.Queryable.to_query()
    |> Repo.all()
  end
end
