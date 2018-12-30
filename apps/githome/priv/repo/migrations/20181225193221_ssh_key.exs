defmodule Githome.Repo.Migrations.SshKey do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :ssh_key, :text
    end
  end
end
