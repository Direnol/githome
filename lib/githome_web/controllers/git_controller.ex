defmodule GithomeWeb.GitController do
  use GithomeWeb, :controller
  import GithomeWeb.GitView

  defp home_dir() do
    case Application.get_env(:githome, :env) do
      :prod -> System.user_home()
      _ -> Path.join(System.user_home(), "workspace")
    end
  end

  defp cmd(command, args, opts \\ []) do
    {ret, err} =
      System.cmd(
        command,
        args,
        Keyword.merge([cd: home_dir() <> "/admin", stderr_to_stdout: true], opts)
      )

    {err, ret}
  end

  defp repo_path(name), do: home_dir() <> "/repositories/" <> name <> ".git"

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
    git_push(project_file, "Create new project: " <> project_name)
  end

  def update_projet(project_name, owner) when is_list(owner) do
    {:ok, project_file} = git_create_project(project_name, owner)
    git_push(project_file, "Update project: " <> project_name)
  end
  def update_project(_, _), do: :no_args

  def delete_project(name) do
    {:ok, _} =
      project_path(name)
      |> File.rm_rf()

    {:ok, _} =
      repo_path(name)
      |> File.rm_rf()

    git_push(".", "Delete project: " <> name)
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

  def update_user(username, ssh) when is_binary(ssh) do
    {:ok, user_file} = git_create_user(username, ssh)
    git_push(user_file, "Update user: " <> username)
  end

  def update_user(_, _), do: :no_args

  def delete_user(username) do
    {:ok, _} =
      user_path(username)
      |> File.rm_rf()

    git_push(".", "Delete user: " <> username)
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

  def update_group(name, members) when is_list(members) do
    {:ok, group_file} = git_create_group(name, members)
    git_push(group_file, "Update group: " <> name)
  end

  def update_group(_, _), do: :no_args

  def delete_group(name) do
    {:ok, _} =
      group_path(name)
      |> File.rm_rf()

    git_push(".", "Delete group:" <> name)
  end

  defp git_push(path, message) do
    git_add(path)
    git_commit(message)
    cmd("git", ["push"])
  end

  def git_log(project, branch, files \\ [], format \\ []) do
    {0, log} = cmd("git", ["log", branch] ++ format ++ ~w[--] ++ files, cd: repo_path(project))
    log
  end

  def git_diff(project, c1, c2, opts \\ []) do
    cmd("git", ["diff", c1, c2] ++ opts, cd: repo_path(project))
  end

  defp git_commit(message) do
    cmd("git", ["commit", "-m", message])
  end

  defp git_add(path) do
    cmd("git", ["add", path])
  end

  defp do_tree([_rules, "blob", _hash, object]), do: {:file, object}
  defp do_tree([_rules, "tree", _hash, object]), do: {:dir, object}

  def git_ls(name, branch, path \\ "", args \\ []) do
    {0, tree} = cmd("git", ~w[ls-tree] ++ [branch <> ":" <> path] ++ args, cd: repo_path(name))

    for o <- String.split(tree, "\n"),
        o != "",
        do: o |> String.replace("\t", " ") |> String.split() |> do_tree
  end

  def git_show(name, branch, path \\ "") do
    {0, res} = cmd("git", ~w[show] ++ [branch <> ":" <> path], cd: repo_path(name))
    res
  end

  defp do_branch(["*", name]), do: {:cur_branch, name}
  defp do_branch([name]), do: {:branch, name}

  @spec git_branches(binary()) :: [any()]
  def git_branches(name) do
    {0, branches} = cmd("git", ~w[branch], cd: repo_path(name))
    for b <- String.split(branches, "\n"), b != "", do: do_branch(String.split(b))
  end
end
