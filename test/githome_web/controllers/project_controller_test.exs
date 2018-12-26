defmodule GithomeWeb.ProjectControllerTest do
  use GithomeWeb.ConnCase

  alias Githome.Projects
  import GithomeWeb.ProjectController
 
  @project_params %{name: "111"} 
  
  describe "project" do
    test "create", %{conn: conn} do
      {st, val} = Projects.create_project(@project_params)
      assert st == :error
    end
  end
  
end
