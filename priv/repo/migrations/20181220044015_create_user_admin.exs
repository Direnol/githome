defmodule Githome.Repo.Migrations.CreateUserAdmin do
  use Ecto.Migration

  def change do
      %{username: "admin", password: "admin", password_confirm: "admin", admin: true}
        |> Githome.Users.create_user()
  end
end
