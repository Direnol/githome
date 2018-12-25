defmodule GithomeWeb.GitController do
  use GithomeWeb, :controller
  import GithomeWeb.GitView

  defp home_dir() do
    case Application.get_env(:githome, :env) do
      :prod -> System.user_home()
      _ -> "/home/direnol/workspace"
    end
  end

  defp cmd(command, args, opts \\ []) do
    {ret, err} =
      System.cmd(command, args, [cd: home_dir() <> "/admin", stderr_to_stdout: true] ++ opts)

    {err, ret}
  end

  defp project_path(project_name) do
    home_dir() <> "/admin/conf/repos/" <> project_name <> ".conf"
  end

  defp git_create_project(project_name, owner) do
    conf = git_render("repo", repo: {project_name, owner})

    proj_file = project_path(project_name)

    ret =
      proj_file
      |> File.write(conf)

    case ret do
      :ok -> {:ok, proj_file}
      err -> err
    end
  end

  def create_project(project_name, owner) do
    {:ok, project_file} = git_create_project(project_name, owner)
    git_push project_file, "Create new project: " <> project_name
  end
  def update_projet(project_name, owner) do
    {:ok, project_file} = git_create_project(project_name, owner)
    git_push project_file, "Update project: " <> project_name
  end

  defp user_path(username) do
    home_dir() <> "/admin/keydir/" <> username <> ".pub"
  end

  defp git_create_user(username, ssh) do
    ssh_file = user_path(username)

    ret =
      ssh_file
      |> File.write(ssh)

    case ret do
      :ok -> {:ok, ssh_file}
      err -> err
    end
  end

  def create_user(username, ssh) do
    {:ok, user_file} = git_create_user(username, ssh)
    git_push(user_file, "Create new user: " <> username)
  end

  def update_user(username, ssh) do
    {:ok, user_file} = git_create_user(username, ssh)
    git_push(user_file, "Update user: " <> username)
  end

  defp group_path(name) do
    home_dir() <> "/admin/conf/groups/" <> name <> ".conf"
  end

  def git_create_group(name, members) do
    group_file = group_path(name)
    conf = git_render("group", group: {name, members})

    ret =
      group_file
      |> File.write(conf)

    case ret do
      :ok -> {:ok, group_file}
      err -> err
    end
  end

  def create_group(name, members) do
    {:ok, group_file} = git_create_group(name, members)
    git_push(group_file, "Create new group: " <> name)
  end

  def update_group(name, members) do
    {:ok, group_file} = git_create_group(name, members)
    git_push(group_file, "Update group: " <> name)
  end

  defp git_push(path, message) do
    git_add(path)
    git_commit(message)
    cmd("git", ["push"])
  end

  def git_log(format \\ []) do
    cmd("git", ["log"] ++ format)
  end

  def git_diff(args) do
    cmd("git", ["diff"] ++ args)
  end

  defp git_commit(message) do
    cmd("git", ["commit", "-m", message])
  end

  defp git_add(path) do
    cmd("git", ["add", path])
  end
end
