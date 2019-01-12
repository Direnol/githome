defmodule Githome.ProjectsTest do
  use Githome.DataCase

  alias Githome.Projects
  alias Githome.Projects.Project

  @valid_attrs %{project_name: "some project_name", description: "some description", owner: 1}
  @update_attrs %{
    description: "some updated description"
  }
  @invalid_attrs %{project_name: nil, owner: nil}

  describe "Empty projects" do
    setup do
      Githome.Repo.delete_all(Project)
      :ok
    end

    test "list_projects/0 returns all projects" do
      assert Projects.list_projects() == []
    end

    test "create_project/1 with valid data creates a project" do
      assert {:ok, project} = Projects.create_project(@valid_attrs)
      assert [project] == Projects.list_projects()
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(@invalid_attrs)
    end
  end

  describe "With projects" do
    setup do
      {:ok, project} = Projects.create_project(@valid_attrs)
      [project: project]
    end

    test "get_project!/1 returns the project with given id", %{project: project} do
      assert Projects.get_project!(project.id) == project
    end

    test "update_project/2 with valid data updates the project", %{project: project} do
      assert {:ok, %Project{} = project} = Projects.update_project(project, @update_attrs)
      assert project.description == "some updated description"
    end

    test "update_project/2 with invalid data returns error changeset", %{project: project} do
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, @invalid_attrs)
      assert project == Projects.get_project!(project.id)
    end

    test "delete_project/1 deletes the project", %{project: project} do
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset", %{project: project} do
      assert %Ecto.Changeset{} = Projects.change_project(project)
    end
  end
end
