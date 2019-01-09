defmodule Githome.Factory do
  use ExMachina.Ecto, repo: Githome.Repo

  alias Githome.Users.User

  def user_factory do
    %User{
      username: sequence(:username, &"Test User #{&1}"),
      password: sequence(:password, &"Test pass #{&1}"),
      password_confirm: sequence(:password_confirm, &"Test pass confirm #{&1}"),
      email: sequence(:email, &"email_#{&1}@noemail.com"),
      admin: false,
      first_name: sequence(:first_name, &"Test firstname #{&1}"),
      last_name: sequence(:last_name, &"Test lastname #{&1}")
    }
  end
end
