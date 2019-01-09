# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Githome.Repo.insert!(%Githome.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

default = [
  %Githome.Users.User{
    username: "admin",
    password_digest: Comeonin.Bcrypt.hashpwsalt("admin"),
    admin: true,
    first_name: "admin",
    last_name: "admin",
  },
  %Githome.Projects.Project{
    project_name: "gitolite-admin",
    description: "Admin project for control",
    owner: 1
  },
  %Githome.GroupInfo.Ginfo{
    name: "admins",
    description: "Admin group"
  },
  %Githome.Members.Member{
    gid: 1,
    uid: 1,
    owner: true
  },
  %Githome.GroupProject.Gp{
    gid: 1,
    pid: 1
  }
]

Enum.each default, &Githome.Repo.insert!/1
