defmodule Githome.MembersTest do
  use Githome.DataCase

  alias Githome.Members
  alias Githome.Users
  alias Githome.GroupProject
  alias Githome.Projects

  @user %{
    email: "test@noemail.com",
    password_confirm: "pass",
    password: "pass",
    username: "user_test"
  }

  @members [
    %{
      email: "member1@noemail.com",
      password_confirm: "pass",
      password: "pass",
      username: "member1"
    },
    %{
      email: "member2@noemail.com",
      password_confirm: "pass",
      password: "pass",
      username: "member2"
    },
    %{
      email: "member3@noemail.com",
      password_confirm: "pass",
      password: "pass",
      username: "member3"
    }
  ]
  @projects [
    %{project_name: "project1", description: "desc project 1", owner: 0},
    %{project_name: "project2", description: "desc project 2", owner: 0},
    %{project_name: "project3", description: "desc project 3", owner: 0},
    %{project_name: "project4", description: "desc project 4", owner: 0}
  ]

  @valid_attrs %{
    "name" => "name",
    "members" => [],
    "projects" => [],
    "desc" => "description",
    "owner" => 0
  }

  # @update_attrs %{gid: 43, owner: false, uid: 43}
  # @invalid_attrs %{gid: nil, owner: nil, uid: nil}
  describe "Empty members" do
    setup do
      {:ok, %{id: id}} = Users.create_user(@user)
      Githome.Repo.delete_all(Members.Member)

      members = Enum.map(@members, &(Users.create_user(&1) |> elem(1) |> Map.get(:id)))

      projects =
        Enum.map(
          Enum.map(@projects, &Map.replace!(&1, :owner, id)),
          &(Projects.create_project(&1) |> elem(1) |> Map.get(:id))
        )

      {:ok, owner: id, members: members, projects: projects}
    end

    test "List of members must be empty" do
      assert Members.list_members() == []
    end

    test "Create new empty group", ctx do
      {:ok, _} = Members.create_group(Map.replace!(@valid_attrs, "owner", ctx.owner))
      [member] = Members.list_members()
      assert member.uid == ctx.owner && member.owner
    end

    test "Create group with members", ctx do
      {:ok, %{id: id}} =
        Members.create_group(
          Map.replace!(@valid_attrs, "owner", ctx.owner)
          |> Map.replace!("members", ctx.members)
        )

      all_members = ctx.members ++ [ctx.owner]

      Members.get_all_members_by_group(id)
      |> Enum.map(& &1.id)
      |> Enum.each(&assert &1 in all_members)
    end

    test "Create group with projects", ctx do
      {:ok, %{id: id}} =
        Members.create_group(
          Map.replace!(@valid_attrs, "owner", ctx.owner)
          |> Map.replace!("projects", ctx.projects)
        )

      GroupProject.get_all_project_by_group(id)
      |> (fn x ->
            assert(length(x) == length(@projects))
            x
          end).()
      |> Enum.map(& &1.owner)
      |> Enum.each(&assert &1 == ctx.owner)
    end

    test "Create group with projects and members", ctx do
      {:ok, %{id: id}} =
        Members.create_group(
          Map.replace!(@valid_attrs, "owner", ctx.owner)
          |> Map.replace!("projects", ctx.projects)
          |> Map.replace!("members", ctx.members)
        )

      GroupProject.get_all_project_by_group(id)
      |> (fn x ->
            assert(length(x) == length(@projects))
            x
          end).()
      |> Enum.map(& &1.owner)
      |> Enum.each(&assert &1 == ctx.owner)

      all_members = ctx.members ++ [ctx.owner]

      Members.get_all_members_by_group(id)
      |> Enum.map(& &1.id)
      |> Enum.each(&assert &1 in all_members)
    end
  end
end

# describe "members" do
#   alias Githome.Members.Member
#   def group_fixture(attrs \\ %{}) do
#     {:ok, group} =
#       attrs
#       |> Enum.into(@valid_attrs)
#       |> Members.create_group()

#     group
#   end
#  test "list_members/0 returns all members" do
#     group = group_fixture()
#     assert Members.list_members() == [group]
#   end

#   test "get_group!/1 returns the group with given id" do
#     group = group_fixture()
#     assert Members.get_group!(group.id) == group
#   end

#   test "create_group/1 with valid data creates a group" do
#     assert {:ok, %Member{} = group} = Members.create_group(@valid_attrs)
#     assert group.gid == 42
#     assert group.uid == 42
#   end

#   test "create_group/1 with invalid data returns error changeset" do
#     assert {:error, %Ecto.Changeset{}} = Members.create_group(@invalid_attrs)
#   end

#   test "update_group/2 with valid data updates the group" do
#     group = group_fixture()
#     assert {:ok, %Member{} = group} = Members.update_group(group, @update_attrs)
#     assert group.gid == 43
#     assert group.uid == 43
#   end

#   test "update_group/2 with invalid data returns error changeset" do
#     group = group_fixture()
#     assert {:error, %Ecto.Changeset{}} = Members.update_group(group, @invalid_attrs)
#     assert group == Members.get_group!(group.id)
#   end

#   test "delete_group/1 deletes the group" do
#     group = group_fixture()
#     assert {:ok, %Member{}} = Members.delete_group(group)
#     assert_raise Ecto.NoResultsError, fn -> Members.get_group!(group.id) end
#   end

#   test "change_group/1 returns a group changeset" do
#     group = group_fixture()
#     assert %Ecto.Changeset{} = Members.change_group(group)
#   end
# end
# end
