defmodule Githome.Members do
  @moduledoc """
  The Members context.
  """

  import Ecto.Query, warn: false
  alias Githome.Repo

  alias Githome.Members.Member
  alias Githome.GroupInfo.Ginfo
  alias Githome.GroupInfo
  alias Githome.GroupProject.Gp
  alias Githome.GroupProject
  alias Githome.Users.User

  @doc """
  Returns the list of Members.

  ## Examples

      iex> list_members()
      [%Member{}, ...]

  """
  def list_members do
    Repo.all(Member)
  end

  def list_my_groups(id) do
    query =
      from(i in Ginfo,
        left_join: g in Member,
        on: i.id == g.gid,
        select: i,
        where: g.uid == ^id
      )

    query
    |> Ecto.Queryable.to_query()
    |> Repo.all()
  end

  @doc """
  Gets a single Member.

  Raises `Ecto.NoResultsError` if the Member does not exist.

  ## Examples

      iex> get_member!(123)
      %Member{}

      iex> get_member!(456)
      ** (Ecto.NoResultsError)

  """
  def get_member!(id), do: Repo.get!(Member, id)
  def get_member_by!(search), do: Repo.get_by!(Member, search)
  def get_member_by(search), do: Repo.get_by(Member, search)

  @doc """
  Creates a Member.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Member{}}

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
          {:ok, _member} ->
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
    %Member{}
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a Member.

  ## Examples

      iex> update_member(Member, %{field: new_value})
      {:ok, %Member{}}

      iex> update_member(Member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_member(%Member{} = member, attrs) do
    member
    |> Member.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Member.

  ## Examples

      iex> delete_group(Group_id)
      {:ok, %Member{}}

      iex> delete_member(Member)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(id) do
    from(i in Ginfo, where: i.id == ^id) |> Repo.delete_all()
    from(g in Member, where: g.gid == ^id) |> Repo.delete_all()
    from(pg in Gp, where: pg.gid == ^id) |> Repo.delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking Member changes.

  ## Examples

      iex> change_member(Member)
      %Ecto.Changeset{source: %Member{}}

  """
  def change_member(%Member{} = member) do
    Member.changeset(member, %{})
  end

  def get_all_members_by_group(id) do
    query =
      from(u in User,
        right_join: gr in Member,
        on: u.id == gr.uid,
        select: u,
        where: gr.gid == ^id
      )

    query
    |> Ecto.Queryable.to_query()
    |> Repo.all()
  end

  def get_owner_by_group(id) do
    query =
      from(g in Member,
        select: g,
        where: g.gid == ^id and g.owner == true
      )

    query
    |> Ecto.Queryable.to_query()
    |> Repo.all()
  end
end
