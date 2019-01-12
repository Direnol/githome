defmodule GithomeWeb.Factory do
  use ExMachina.Ecto, repo: Githome.Repo

  alias Githome.Users.User
  alias Githome.Projects.Project

  def user_factory do
    %User{
      username: sequence(:username, &"Test_User_#{&1}"),
      password: sequence(:password, &"Test_pass_#{&1}"),
      password_confirm: sequence(:password_confirm, &"Test_pass_#{&1}"),
      password_digest: sequence(:password_digest, &Comeonin.Bcrypt.hashpwsalt("Test_pass_#{&1}")),
      email: sequence(:email, &"email_#{&1}@noemail.com"),
      admin: false,
      first_name: sequence(:first_name, &"Test firstname #{&1}"),
      last_name: sequence(:last_name, &"Test lastname #{&1}")
    }
  end

  def project_factory do
    %Project{
      project_name: sequence(:project_name, &"Test project #{&1}"),
      description: sequence(:description, &"Test description #{&1}"),
      owner: 1
    }
  end
end
